package member;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

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

    // 1. 회원가입
    public void insertMember(MemberVO member) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO MEMBER (id, password, name, nickname, email, phone, auth_status, role) VALUES (?, ?, ?, ?, ?, ?, 'Y', 'USER')";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getId());
            pstmt.setString(2, member.getPassword() != null ? member.getPassword() : member.getPass());
            pstmt.setString(3, member.getName());
            pstmt.setString(4, (member.getNickname() != null && !member.getNickname().isEmpty()) ? member.getNickname() : member.getName());
            pstmt.setString(5, member.getEmail() != null ? member.getEmail() : "");
            // 전화번호는 선택 사항: 입력하지 않았으면 NULL로 저장
            pstmt.setString(6, (member.getPhone() != null && !member.getPhone().isEmpty()) ? member.getPhone() : null);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 2. 아이디 중복 검사 (idCheck, checkId 모두 지원)
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
                x = 1; // 중복 아이디
            } else {
                x = 0; // 사용 가능
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

    // 3. 로그인 인증
    public int userCheck(String id, String password) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int x = -1;

        try {
            conn = getConnection();
            String sql = "SELECT password FROM MEMBER WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id != null ? id.trim() : "");
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String dbPassword = rs.getString("password");
                
                if (dbPassword != null && password != null && dbPassword.trim().equals(password.trim())) {
                    x = 1; // 로그인 성공
                } else {
                    x = 0; // 비밀번호 불일치
                }
            } else {
                x = -1; // 회원 없음
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return x;
    }

    // 4. 회원 상세 정보 조회
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
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return vo;
    }
    // 5-1. 회원 정보 수정 (닉네임/이름/이메일, 새 비밀번호가 있으면 비밀번호도 변경)
    public boolean updateMember(MemberVO member, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean changePw = newPassword != null && !newPassword.isEmpty();

        try {
            conn = getConnection();
            String sql = changePw
            		? "UPDATE MEMBER SET nickname = ?, name = ?, email = ?, password = ?, info_changed_at = NOW(), pw_changed_at = NOW() WHERE id = ?"
                            : "UPDATE MEMBER SET nickname = ?, name = ?, email = ?, info_changed_at = NOW() WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            pstmt.setString(idx++, member.getNickname());
            pstmt.setString(idx++, member.getName());
            pstmt.setString(idx++, member.getEmail());
            if (changePw) pstmt.setString(idx++, newPassword);
            pstmt.setString(idx, member.getId());
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
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
            pstmt = conn.prepareStatement("UPDATE MEMBER SET nickname = ?, info_changed_at = NOW() WHERE id = ?");
            pstmt.setString(1, nickname);
            pstmt.setString(2, id);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
        return false;
    }
    // 5-2. 회원 탈퇴
    //  - 내가 추천했던 다른 사람 글의 추천 수를 먼저 1씩 줄이고
    //  - MEMBER 삭제 → 내 글/댓글/추천/알림/체크리스트는 FK(ON DELETE CASCADE)로 함께 삭제
    //  - 성공하면 서버에서 지워야 할 첨부파일 이름 목록을 돌려줌 (실패 시 null)
    public java.util.List<String> deleteMember(String id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        java.util.List<String> savedNames = new java.util.ArrayList<String>();

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1) 내 글에 붙은 첨부파일 이름 (DB 행은 CASCADE로 지워지지만 실제 파일은 직접 지워야 함)
            pstmt = conn.prepareStatement(
                "SELECT f.saved_name FROM BOARD_FILE f JOIN BOARD b ON b.num = f.board_num WHERE b.writer_id = ?");
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            while (rs.next()) savedNames.add(rs.getString(1));
            rs.close(); rs = null;
            pstmt.close();

            // 2) 내가 추천한 (다른 사람) 글의 추천 수 감소
            pstmt = conn.prepareStatement(
                "UPDATE BOARD SET like_count = GREATEST(0, IFNULL(like_count, 0) - 1) "
              + "WHERE num IN (SELECT board_num FROM BOARD_LIKE WHERE user_id = ?) AND (writer_id IS NULL OR writer_id <> ?)");
            pstmt.setString(1, id);
            pstmt.setString(2, id);
            pstmt.executeUpdate();
            pstmt.close();

            // 3) 회원 삭제 (연결된 데이터는 FK CASCADE로 함께 삭제)
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
    // 5. 전체 회원 수 조회
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
    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}