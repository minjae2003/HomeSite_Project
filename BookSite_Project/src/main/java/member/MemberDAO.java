package member;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import util.PasswordUtil;

public class MemberDAO {
    private static MemberDAO instance = new MemberDAO();
    public static MemberDAO getInstance() { return instance; }
    private MemberDAO() {}

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public boolean insertMember(MemberVO member) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO MEMBER (id, password, name, nickname, email, phone, auth_status, role) VALUES (?, ?, ?, ?, ?, ?, 'Y', 'USER')";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getId());
            // 비밀번호는 평문이 아니라 해시로 저장
            pstmt.setString(2, PasswordUtil.hash(member.getPassword() != null ? member.getPassword() : member.getPass()));
            pstmt.setString(3, member.getName());
            pstmt.setString(4, (member.getNickname() != null && !member.getNickname().isEmpty()) ? member.getNickname() : member.getName());
            pstmt.setString(5, member.getEmail() != null ? member.getEmail() : "");
            pstmt.setString(6, (member.getPhone() != null && !member.getPhone().isEmpty()) ? member.getPhone() : null);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    public int idCheck(String id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int x = 0;

        try {
            conn = getConnection();
            String sql = "SELECT id FROM MEMBER WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                x = 1;
            } else {
                x = 0;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return x;
    }

    public int checkId(String id) {
        return idCheck(id);
    }

    public int userCheck(String id, String password) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int x = -1;
        String loginId = id != null ? id.trim() : "";
        boolean needUpgrade = false;

        try {
            conn = getConnection();
            String sql = "SELECT password FROM MEMBER WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String dbPassword = rs.getString("password");

                if (PasswordUtil.isHashed(dbPassword)) {
                    x = PasswordUtil.verify(password, dbPassword) ? 1 : 0;
                } else if (dbPassword != null && password != null
                        && java.security.MessageDigest.isEqual(
                            dbPassword.trim().getBytes("UTF-8"), password.trim().getBytes("UTF-8"))) {
                    // 예전에 평문으로 저장된 계정 → 로그인 성공 시 해시로 바꿔서 다시 저장
                    x = 1;
                    needUpgrade = true;
                } else {
                    x = 0;
                }
            } else {
                x = -1;
                PasswordUtil.dummyVerify(password);   // 없는 아이디도 응답 시간을 비슷하게 (아이디 존재 여부 노출 방지)
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }

        if (needUpgrade) upgradePassword(loginId, password);
        return x;
    }

    /** 평문 비밀번호를 해시로 교체 (로그인 때 입력한 값 그대로 해시. pw_changed_at은 건드리지 않음 - 사용자가 바꾼 게 아니므로) */
    private void upgradePassword(String id, String rawPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("UPDATE MEMBER SET password = ? WHERE id = ? AND password NOT LIKE 'pbkdf2$%'");
            pstmt.setString(1, PasswordUtil.hash(rawPassword));
            pstmt.setString(2, id);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    /** 아직 평문으로 남아 있는 비밀번호를 한 번에 해시로 변환 (배포 직후 관리자가 1회 실행) - 변환한 개수 반환 */
    public int migratePlainPasswords() {
        Connection conn = null;
        PreparedStatement sel = null, upd = null;
        ResultSet rs = null;
        int count = 0;
        try {
            conn = getConnection();
            sel = conn.prepareStatement("SELECT id, password FROM MEMBER WHERE password NOT LIKE 'pbkdf2$%'");
            upd = conn.prepareStatement("UPDATE MEMBER SET password = ? WHERE id = ? AND password = ?");
            rs = sel.executeQuery();
            while (rs.next()) {
                String id = rs.getString("id");
                String plain = rs.getString("password");
                if (plain == null) continue;
                upd.setString(1, PasswordUtil.hash(plain.trim()));
                upd.setString(2, id);
                upd.setString(3, plain);
                count += upd.executeUpdate();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            if (upd != null) try { upd.close(); } catch (Exception e) {}
            close(conn, sel, rs);
        }
        return count;
    }

    public MemberVO getMember(String id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        MemberVO vo = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM MEMBER WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vo = new MemberVO();
                vo.setId(rs.getString("id"));
                vo.setPassword(rs.getString("password"));
                vo.setName(rs.getString("name"));
                vo.setNickname(rs.getString("nickname"));
                vo.setEmail(rs.getString("email"));
                vo.setRole(rs.getString("role"));
                vo.setRegDate(rs.getTimestamp("reg_date"));
                vo.setEmail(rs.getString("email"));
                try { vo.setPhone(rs.getString("phone")); } catch (Exception e) {}
                try { vo.setPwChangedAt(rs.getTimestamp("pw_changed_at")); } catch (Exception e) {}
                try { vo.setInfoChangedAt(rs.getTimestamp("info_changed_at")); } catch (Exception e) {}
                try { vo.setSuspendUntil(rs.getTimestamp("suspend_until")); vo.setSuspendReason(rs.getString("suspend_reason")); } catch (Exception e) {}
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return vo;
    }
    public java.util.List<String> findIds(String name, String email) {
        java.util.List<String> ids = new java.util.ArrayList<String>();
        if (isBlank(name) || isBlank(email)) return ids;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "SELECT id FROM MEMBER WHERE name = ? AND LOWER(email) = LOWER(?) AND email <> '' ORDER BY reg_date");
            pstmt.setString(1, name.trim());
            pstmt.setString(2, email.trim());
            rs = pstmt.executeQuery();
            while (rs.next()) ids.add(rs.getString(1));
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return ids;
    }

    public boolean matchForReset(String id, String name, String email) {
        if (isBlank(id) || isBlank(name) || isBlank(email)) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "SELECT 1 FROM MEMBER WHERE id = ? AND name = ? AND LOWER(email) = LOWER(?) AND email <> ''");
            pstmt.setString(1, id.trim());
            pstmt.setString(2, name.trim());
            pstmt.setString(3, email.trim());
            rs = pstmt.executeQuery();
            return rs.next();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return false;
    }

    public boolean resetPassword(String id, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("UPDATE MEMBER SET password = ?, pw_changed_at = NOW() WHERE id = ?");
            pstmt.setString(1, PasswordUtil.hash(newPassword));
            pstmt.setString(2, id);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
        return false;
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
    public boolean updateMember(MemberVO member, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean changePw = newPassword != null && !newPassword.isEmpty();

        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            String sql = changePw
            		? "UPDATE MEMBER SET nickname = ?, name = ?, email = ?, phone = ?, password = ?, info_changed_at = NOW(), pw_changed_at = NOW() WHERE id = ?"
                            : "UPDATE MEMBER SET nickname = ?, name = ?, email = ?, phone = ?, info_changed_at = NOW() WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            pstmt.setString(idx++, member.getNickname());
            pstmt.setString(idx++, member.getName());
            pstmt.setString(idx++, member.getEmail());
            pstmt.setString(idx++, (member.getPhone() != null && !member.getPhone().isEmpty()) ? member.getPhone() : null);
            if (changePw) pstmt.setString(idx++, PasswordUtil.hash(newPassword));
            pstmt.setString(idx, member.getId());
            if (pstmt.executeUpdate() != 1) { conn.rollback(); return false; }
            syncNickname(conn, member.getId(), member.getNickname());
            conn.commit();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            rollback(conn);
        } finally {
            close(conn, pstmt, null);
        }
        return false;
    }
    public boolean updateNickname(String id, String nickname) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            pstmt = conn.prepareStatement("UPDATE MEMBER SET nickname = ?, info_changed_at = NOW() WHERE id = ?");
            pstmt.setString(1, nickname);
            pstmt.setString(2, id);
            if (pstmt.executeUpdate() != 1) { conn.rollback(); return false; }
            syncNickname(conn, id, nickname);
            conn.commit();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            rollback(conn);
        } finally {
            close(conn, pstmt, null);
        }
        return false;
    }
    private void syncNickname(Connection conn, String id, String nickname) throws java.sql.SQLException {
        String[] sqls = {
            "UPDATE BOARD SET writer = ?, writer_nickname = ? WHERE writer_id = ?",
            "UPDATE BOARD_COMMENT SET writer = ?, writer_nickname = ? WHERE writer_id = ?",
        };
        for (String sql : sqls) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nickname);
                ps.setString(2, nickname);
                ps.setString(3, id);
                ps.executeUpdate();
            }
        }
        try (PreparedStatement ps = conn.prepareStatement("UPDATE NOTIFICATION SET actor_nickname = ? WHERE actor_id = ?")) {
            ps.setString(1, nickname);
            ps.setString(2, id);
            ps.executeUpdate();
        }
    }
    private void rollback(Connection conn) {
        if (conn != null) try { conn.rollback(); } catch (Exception e) {}
    }
    public java.util.List<String> deleteMember(String id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        java.util.List<String> savedNames = new java.util.ArrayList<String>();

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            pstmt = conn.prepareStatement(
                "SELECT f.saved_name FROM BOARD_FILE f JOIN BOARD b ON b.num = f.board_num WHERE b.writer_id = ?");
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            while (rs.next()) savedNames.add(rs.getString(1));
            rs.close(); rs = null;
            pstmt.close();

            pstmt = conn.prepareStatement(
                "UPDATE BOARD SET like_count = GREATEST(0, IFNULL(like_count, 0) - 1) "
              + "WHERE num IN (SELECT board_num FROM BOARD_LIKE WHERE user_id = ?) AND (writer_id IS NULL OR writer_id <> ?)");
            pstmt.setString(1, id);
            pstmt.setString(2, id);
            pstmt.executeUpdate();
            pstmt.close();

            pstmt = conn.prepareStatement("DELETE FROM MEMBER WHERE id = ?");
            pstmt.setString(1, id);
            int deleted = pstmt.executeUpdate();

            if (deleted != 1) {
                conn.rollback();
                return null;
            }
            conn.commit();
            return savedNames;
        } catch (Exception ex) {
            ex.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception e) {}
            return null;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) {}
            close(conn, pstmt, rs);
        }
    }
    public int getMemberCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM MEMBER";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return count;
    }
    // ===== 관리자 회원 관리 =====

    private static String adminWhere(String keyword, String filter) {
        StringBuilder w = new StringBuilder(" WHERE 1 = 1");
        if (keyword != null && !keyword.isEmpty()) w.append(" AND (m.id LIKE ? OR m.nickname LIKE ? OR m.name LIKE ? OR m.email LIKE ?)");
        if ("SUSPENDED".equals(filter)) w.append(" AND m.suspend_until > NOW()");
        else if ("ADMIN".equals(filter)) w.append(" AND m.role = 'ADMIN'");
        return w.toString();
    }

    private static int bindKeyword(PreparedStatement pstmt, String keyword) throws java.sql.SQLException {
        int idx = 1;
        if (keyword != null && !keyword.isEmpty()) {
            String like = "%" + keyword.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
            for (int k = 0; k < 4; k++) pstmt.setString(idx++, like);
        }
        return idx;
    }

    /** 관리자: 회원 수 (검색어, 필터 ALL/SUSPENDED/ADMIN). 오류 시 -1 */
    public int adminCount(String keyword, String filter) {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT COUNT(*) FROM MEMBER m" + adminWhere(keyword, filter));
            bindKeyword(pstmt, keyword);
            rs = pstmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return -1;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    /** 관리자: 회원 목록 (최근 가입순, 글·댓글 수 포함) */
    public java.util.List<MemberVO> adminList(String keyword, String filter, int start, int count) {
        java.util.List<MemberVO> list = new java.util.ArrayList<MemberVO>();
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "SELECT m.id, m.name, m.nickname, m.email, m.role, m.reg_date, m.suspend_until, m.suspend_reason, "
              + "(SELECT COUNT(*) FROM BOARD b WHERE b.writer_id = m.id) AS post_cnt, "
              + "(SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.writer_id = m.id) AS comment_cnt "
              + "FROM MEMBER m" + adminWhere(keyword, filter)
              + " ORDER BY m.reg_date DESC, m.id LIMIT ?, ?");
            int idx = bindKeyword(pstmt, keyword);
            pstmt.setInt(idx++, Math.max(0, start));
            pstmt.setInt(idx, count);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                MemberVO vo = new MemberVO();
                vo.setId(rs.getString("id"));
                vo.setName(rs.getString("name"));
                vo.setNickname(rs.getString("nickname"));
                vo.setEmail(rs.getString("email"));
                vo.setRole(rs.getString("role"));
                vo.setRegDate(rs.getTimestamp("reg_date"));
                vo.setSuspendUntil(rs.getTimestamp("suspend_until"));
                vo.setSuspendReason(rs.getString("suspend_reason"));
                vo.setPostCount(rs.getInt("post_cnt"));
                vo.setCommentCount(rs.getInt("comment_cnt"));
                list.add(vo);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        } finally {
            close(conn, pstmt, rs);
        }
        return list;
    }

    /** 관리자: 이용 정지 (days가 0 이하면 영구). 관리자 계정은 정지할 수 없음 */
    public boolean suspend(String id, int days, String reason) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(days > 0
                ? "UPDATE MEMBER SET suspend_until = NOW() + INTERVAL ? DAY, suspend_reason = ? WHERE id = ? AND role <> 'ADMIN'"
                : "UPDATE MEMBER SET suspend_until = '9999-12-31 23:59:59', suspend_reason = ? WHERE id = ? AND role <> 'ADMIN'");
            int idx = 1;
            if (days > 0) pstmt.setInt(idx++, days);
            pstmt.setString(idx++, reason);
            pstmt.setString(idx, id);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    /** 관리자: 정지 해제 */
    public boolean unsuspend(String id) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("UPDATE MEMBER SET suspend_until = NULL, suspend_reason = NULL WHERE id = ?");
            pstmt.setString(1, id);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    /** 이용 정지 종료 시각 (정지 중이 아니면 null, 오류 시에도 null) */
    public java.sql.Timestamp getActiveSuspension(String id) {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT suspend_until FROM MEMBER WHERE id = ? AND suspend_until > NOW()");
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            return rs.next() ? rs.getTimestamp(1) : null;
        } catch (Exception ex) {
            return null;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.setAutoCommit(true); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}