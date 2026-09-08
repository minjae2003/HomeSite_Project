package freeboard;

import java.sql.*;
import java.util.*;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class FreeboardDAO {

    private static FreeboardDAO instance = new FreeboardDAO();

    public static FreeboardDAO getInstance() {
        return instance;
    }

    private FreeboardDAO() {}

    private Connection getConnection() {
        Connection conn = null;

        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/basicjsp");
            conn = ds.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return conn;
    }

    public int getFreeboardCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        int count = 0;

        try {
            conn = getConnection();

            String sql = "select count(*) from freeboard";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if(rs.next()) {
                count = rs.getInt(1);
            }

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(rs != null) try { rs.close(); } catch(SQLException se) {}
            if(pstmt != null) try { pstmt.close(); } catch(SQLException se) {}
            if(conn != null) try { conn.close(); } catch(SQLException se) {}
        }

        return count;
    }

    public List<FreeboardVO> getFreeboards(int start, int end) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        List<FreeboardVO> fbList = new ArrayList<FreeboardVO>();

        try {
            conn = getConnection();

            String sql = "select * from freeboard order by num desc limit ?, ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start-1);
            pstmt.setInt(2, end);
            rs = pstmt.executeQuery();

            while(rs.next()) {
                FreeboardVO fb = new FreeboardVO();

                fb.setNum(rs.getInt("num"));
                fb.setWriter(rs.getString("writer"));
                fb.setSubject(rs.getString("subject"));
                fb.setReg_date(rs.getTimestamp("reg_date"));
                fb.setReadcount(rs.getInt("readcount"));
                fb.setContent(rs.getString("content"));

                fbList.add(fb);
            }

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(rs != null) try { rs.close(); } catch(SQLException se) {}
            if(pstmt != null) try { pstmt.close(); } catch(SQLException se) {}
            if(conn != null) try { conn.close(); } catch(SQLException se) {}
        }

        return fbList;
    }

    public FreeboardVO getFreeboard(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        FreeboardVO fb = null;

        try {
            conn = getConnection();

            String sql = "update freeboard set readcount = readcount + 1 where num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            pstmt.executeUpdate();

            pstmt.close();

            sql = "select * from freeboard where num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            rs = pstmt.executeQuery();

            if(rs.next()) {
                fb = new FreeboardVO();

                fb.setNum(rs.getInt("num"));
                fb.setWriter(rs.getString("writer"));
                fb.setSubject(rs.getString("subject"));
                fb.setReg_date(rs.getTimestamp("reg_date"));
                fb.setReadcount(rs.getInt("readcount"));
                fb.setContent(rs.getString("content"));
            }

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(rs != null) try { rs.close(); } catch(SQLException se) {}
            if(pstmt != null) try { pstmt.close(); } catch(SQLException se) {}
            if(conn != null) try { conn.close(); } catch(SQLException se) {}
        }

        return fb;
    }

    public void insertFreeboard(FreeboardVO fb) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();

            String sql = "insert into freeboard(writer, subject, reg_date, content) values (?, ?, now(), ?)";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, fb.getWriter());
            pstmt.setString(2, fb.getSubject());
            pstmt.setString(3, fb.getContent());

            pstmt.executeUpdate();

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(pstmt != null) try { pstmt.close(); } catch(SQLException se) {}
            if(conn != null) try { conn.close(); } catch(SQLException se) {}
        }
    }
    
    public void deleteFreeboard(int num) {

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            
            String sql = "delete from replyfreeboard where ref=?";
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, num);

            pstmt.executeUpdate();

            sql = "delete from freeboard where num=?";
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, num);

            pstmt.executeUpdate();

        } catch(Exception e) {
            e.printStackTrace();

        } finally {
            if(pstmt != null)
                try { pstmt.close(); } catch(SQLException se) {}

            if(conn != null)
                try { conn.close(); } catch(SQLException se) {}
        }
    }
}