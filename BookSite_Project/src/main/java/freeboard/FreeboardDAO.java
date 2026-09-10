package freeboard;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class FreeboardDAO {

    private static FreeboardDAO instance = new FreeboardDAO();

    public static FreeboardDAO getInstance() {
        return instance;
    }

    private FreeboardDAO() {}

    // DB 연결 메서드 (프로젝트 설정에 맞는 방식 사용)
    private Connection getConnection() throws Exception {
        // DBCP/JNDI 방식을 사용할 경우
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/oracle"); // 프로젝트 JNDI 이름
        return ds.getConnection();

        /* DriverManager 사용 시 아래 주석 해제 후 수정
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "db_id", "db_pw");
        */
    }

    // 1. 전체 게시글 수 조회
    public int getFreeboardCount() {
        int x = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("select count(*) from freeboard");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                x = rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return x;
    }

    // 2. 카테고리별 게시글 수 조회 (오버로딩)
    public int getFreeboardCount(String category) {
        int x = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql = "";

            if ("popular".equals(category)) {
                sql = "select count(*) from freeboard where readcount >= 50";
                pstmt = conn.prepareStatement(sql);
            } else {
                sql = "select count(*) from freeboard where category = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, category);
            }

            rs = pstmt.executeQuery();
            if (rs.next()) {
                x = rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return x;
    }

    // 3. 전체 게시글 목록 조회
    public List<FreeboardVO> getFreeboards(int start, int end) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<FreeboardVO> articleList = null;

        try {
            conn = getConnection();
            String sql = "select * from (select rownum rnum, num, writer, subject, email, content, password, reg_date, readcount, category " +
                         "from (select * from freeboard order by num desc)) where rnum >= ? and rnum <= ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, start + end - 1);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                articleList = new ArrayList<FreeboardVO>();
                do {
                    FreeboardVO article = new FreeboardVO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setEmail(rs.getString("email"));
                    article.setContent(rs.getString("content"));
                    article.setPassword(rs.getString("password"));
                    article.setReg_date(rs.getTimestamp("reg_date"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setCategory(rs.getString("category"));
                    articleList.add(article);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return articleList;
    }

    // 4. 카테고리별 게시글 목록 조회 (오버로딩)
    public List<FreeboardVO> getFreeboards(String category, int start, int end) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<FreeboardVO> articleList = null;

        try {
            conn = getConnection();
            String sql = "";

            if ("popular".equals(category)) {
                sql = "select * from (select rownum rnum, num, writer, subject, email, content, password, reg_date, readcount, category " +
                      "from (select * from freeboard where readcount >= 50 order by num desc)) where rnum >= ? and rnum <= ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, start);
                pstmt.setInt(2, start + end - 1);
            } else {
                sql = "select * from (select rownum rnum, num, writer, subject, email, content, password, reg_date, readcount, category " +
                      "from (select * from freeboard where category = ? order by num desc)) where rnum >= ? and rnum <= ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, category);
                pstmt.setInt(2, start);
                pstmt.setInt(3, start + end - 1);
            }

            rs = pstmt.executeQuery();
            if (rs.next()) {
                articleList = new ArrayList<FreeboardVO>();
                do {
                    FreeboardVO article = new FreeboardVO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setEmail(rs.getString("email"));
                    article.setContent(rs.getString("content"));
                    article.setPassword(rs.getString("password"));
                    article.setReg_date(rs.getTimestamp("reg_date"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setCategory(rs.getString("category"));
                    articleList.add(article);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return articleList;
    }
}