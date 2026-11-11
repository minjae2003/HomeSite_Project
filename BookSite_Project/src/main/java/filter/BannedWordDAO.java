package filter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/** 금칙어(BAN) / 예외 단어(ALLOW) 목록 (BANNED_WORD) */
public class BannedWordDAO {
    private static final BannedWordDAO instance = new BannedWordDAO();
    public static BannedWordDAO getInstance() { return instance; }
    private BannedWordDAO() {}

    /** 처음 쓸 때 관리자 화면에서 한 번에 넣을 수 있는 기본 목록 */
    public static final String[] DEFAULT_BAN = {
        "씨발", "시발", "씨바", "씨팔", "시팔", "ㅅㅂ", "ㅆㅂ", "병신", "ㅂㅅ", "ㅄ", "좆", "존나",
        "개새끼", "개새기", "개색기", "개색끼", "미친놈", "미친년", "지랄", "염병", "엠창", "니미",
        "느금마", "느개비", "썅", "닥쳐", "fuck", "shit", "bitch",
        "바카라", "카지노사이트", "토토사이트", "먹튀검증"
    };
    public static final String[] DEFAULT_ALLOW = { "시발점", "시발역" };

    public static class Word {
        public final int id; public final String word; public final String type;
        Word(int id, String word, String type) { this.id = id; this.word = word; this.type = type; }
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    /** 전체 목록. DB 오류면 null */
    public List<Word> list() {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT word_id, word, type FROM BANNED_WORD ORDER BY type, word");
            rs = pstmt.executeQuery();
            List<Word> list = new ArrayList<Word>();
            while (rs.next()) list.add(new Word(rs.getInt(1), rs.getString(2), rs.getString(3)));
            return list;
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    /** 추가 (이미 있으면 무시). 성공 여부 */
    public boolean add(String word, String type) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("INSERT IGNORE INTO BANNED_WORD (word, type) VALUES (?, ?)");
            pstmt.setString(1, word);
            pstmt.setString(2, type);
            pstmt.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    public boolean delete(int wordId) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("DELETE FROM BANNED_WORD WHERE word_id = ?");
            pstmt.setInt(1, wordId);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    /** 기본 목록 넣기 (이미 있는 단어는 건너뜀) */
    public void addDefaults() {
        for (String w : DEFAULT_BAN) add(w, "BAN");
        for (String w : DEFAULT_ALLOW) add(w, "ALLOW");
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}
