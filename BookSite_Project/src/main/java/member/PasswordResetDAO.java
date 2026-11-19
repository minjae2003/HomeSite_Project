package member;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/**
 * 비밀번호 재설정 링크 토큰.
 * - 토큰 원본은 메일로만 보내고 DB에는 SHA-256 값만 저장 (DB가 유출돼도 링크를 만들 수 없음)
 * - 30분 동안 한 번만 사용 가능, 새로 요청하면 이전 링크는 무효
 */
public class PasswordResetDAO {
    public static final long VALID_MS = 30 * 60 * 1000L;

    private static final PasswordResetDAO instance = new PasswordResetDAO();
    private static final SecureRandom RANDOM = new SecureRandom();

    public static PasswordResetDAO getInstance() { return instance; }
    private PasswordResetDAO() {}

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    /** 새 토큰을 만들어 저장하고 원본(메일 링크용)을 돌려준다. 실패하면 null */
    public String create(String memberId) {
        byte[] raw = new byte[32];
        RANDOM.nextBytes(raw);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        long now = System.currentTimeMillis();
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM PASSWORD_RESET WHERE member_id = ? OR expires_at < ?")) {
                ps.setString(1, memberId);
                ps.setLong(2, now);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO PASSWORD_RESET (token_hash, member_id, expires_at, created_at) VALUES (?, ?, ?, ?)")) {
                ps.setString(1, hash(token));
                ps.setString(2, memberId);
                ps.setLong(3, now + VALID_MS);
                ps.setLong(4, now);
                ps.executeUpdate();
            }
            return token;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /** 유효한 토큰이면 회원 아이디, 아니면 null (사용 처리는 하지 않음) */
    public String peek(String token) {
        if (!wellFormed(token)) return null;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT member_id FROM PASSWORD_RESET WHERE token_hash = ? AND expires_at > ?")) {
            ps.setString(1, hash(token));
            ps.setLong(2, System.currentTimeMillis());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /** 토큰을 사용 처리(삭제)하고 회원 아이디를 돌려준다. 이미 쓰였거나 만료면 null */
    public String consume(String token) {
        String memberId = peek(token);
        if (memberId == null) return null;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM PASSWORD_RESET WHERE token_hash = ?")) {
            ps.setString(1, hash(token));
            return ps.executeUpdate() == 1 ? memberId : null;   // 동시에 두 번 눌러도 한 번만 성공
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /** 회원의 남은 링크를 모두 무효화 (비밀번호 변경 후) */
    public void deleteAll(String memberId) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM PASSWORD_RESET WHERE member_id = ?")) {
            ps.setString(1, memberId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static boolean wellFormed(String token) {
        return token != null && token.matches("[A-Za-z0-9_-]{43}");
    }

    static String hash(String token) throws Exception {
        byte[] d = MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : d) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
