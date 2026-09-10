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
            String sql = "INSERT INTO MEMBER (id, password, name, nickname, email, auth_status, role) VALUES (?, ?, ?, ?, ?, 'Y', 'USER')";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getId());
            pstmt.setString(2, member.getPassword() != null ? member.getPassword() : member.getPass());
            pstmt.setString(3, member.getName());
            pstmt.setString(4, (member.getNickname() != null && !member.getNickname().isEmpty()) ? member.getNickname() : member.getName());
            pstmt.setString(5, member.getEmail() != null ? member.getEmail() : "");
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
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return vo;
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}