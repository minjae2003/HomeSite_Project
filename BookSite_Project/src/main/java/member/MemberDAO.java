package member;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


import javax.naming.InitialContext;
import javax.sql.DataSource;

public class MemberDAO {

    // 싱글톤 패턴
    private static MemberDAO instance = new MemberDAO();

    public static MemberDAO getInstance() {
        return instance;
    }

    private MemberDAO() { }

    // DB 연결 메서드
    private Connection getConnection() {
        Connection conn = null;

        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/basicjsp");
            conn = ds.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("DB 연결에 문제가 생겼습니다.");
        }

        return conn;
    }



    // 회원가입
    public void insertMember(MemberVO member) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();

            String sql = "insert into member(id, passwd, name, reg_date) values (?, ?, ?, now())";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, member.getId());
            pstmt.setString(2, member.getPasswd());
            pstmt.setString(3, member.getName());

            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("member 테이블의 레코드 추가에 문제가 생겼습니다.");

        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException se) {}
            if (conn != null) try { conn.close(); } catch (SQLException se) {}
        }
    }

    // 로그인 체크
    public int userCheck(String id, String passwd) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        int x = -1;
        // 1  : 로그인 성공
        // 0  : 비밀번호 틀림
        // -1 : 아이디 없음

        try {
            conn = getConnection();

            String sql = "select passwd from member where id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                String dbPasswd = rs.getString("passwd");

                if (dbPasswd.equals(passwd)) {
                    x = 1;
                } else {
                    x = 0;
                }
            } else {
                x = -1;
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("로그인 체크 중 문제가 생겼습니다.");

        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException se) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException se) {}
            if (conn != null) try { conn.close(); } catch (SQLException se) {}
        }

        return x;
    }
    
    public int idCheck(String id ) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        int x = -1;
        // 1  : 로그인 성공
        // 0  : 비밀번호 틀림
        // -1 : 아이디 없음

        try {
            conn = getConnection();

            String sql = "select passwd from member where id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);

            rs = pstmt.executeQuery();

            if (rs.next()) {
            	x = 1;
            } else {
                x = -1;
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("아이디 확인 중 문제가 생겼습니다.");

        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException se) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException se) {}
            if (conn != null) try { conn.close(); } catch (SQLException se) {}
        }

        return x;
    }
}