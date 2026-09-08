package replyfreeboard;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import freeboard.FreeboardVO;

public class ReplyfreeboardDAO {

    private static ReplyfreeboardDAO instance = new ReplyfreeboardDAO();

    public static ReplyfreeboardDAO getInstance() {
        return instance;
    }

    private ReplyfreeboardDAO() {}

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

    public int getReplyFreeboardCount(int ref) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        int count = 0;

        try {
            conn = getConnection();

            String sql = "select count(*) from replyfreeboard where ref=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, ref);
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

    public List<ReplyfreeboardVO> getReplyFreeboards(int ref) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        List<ReplyfreeboardVO> rfbList = new ArrayList<ReplyfreeboardVO>();

        try {
            conn = getConnection();

            String sql = "select * from replyfreeboard where ref=? order by rnum";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, ref);
            rs = pstmt.executeQuery();

            while(rs.next()) {
                ReplyfreeboardVO rfb = new ReplyfreeboardVO();

                rfb.setRnum(rs.getInt("rnum"));
                rfb.setRwriter(rs.getString("rwriter"));
                rfb.setReply(rs.getString("reply"));
                rfb.setRreg_date(rs.getTimestamp("rreg_date"));
                rfb.setRef(rs.getInt("ref"));

                rfbList.add(rfb);
            }

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(rs != null) try { rs.close(); } catch(SQLException se) {}
            if(pstmt != null) try { pstmt.close(); } catch(SQLException se) {}
            if(conn != null) try { conn.close(); } catch(SQLException se) {}
        }

        return rfbList;
    }
    
    public void insertReplyfreeboard(ReplyfreeboardVO rfb) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
//            insert into replyfreeboard(rwriter, reply, rreg_date, ref)
//            values ('aaa', 'hello~', now(), 1);
            String sql = "insert into replyfreeboard(rwriter, reply, rreg_date, ref) values (?, ?, now(), ?)";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, rfb.getRwriter());
            pstmt.setString(2, rfb.getReply());
            pstmt.setInt(3, rfb.getRef());

            pstmt.executeUpdate();

        } catch(Exception e) {
            e.printStackTrace();
            System.out.println(" select에 문제가 생겼습니다.");
        } finally {
            if(pstmt != null) try { pstmt.close(); } catch(SQLException se) {}
            if(conn != null) try { conn.close(); } catch(SQLException se) {}
        }
    }
    
    public void deleteReplyfreeboard(int rnum) {

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();

            String sql = "delete from replyfreeboard where rnum=?";
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, rnum);

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