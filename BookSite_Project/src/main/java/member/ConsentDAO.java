package member;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class ConsentDAO {
    private static final ConsentDAO instance = new ConsentDAO();
    public static ConsentDAO getInstance() { return instance; }
    private ConsentDAO() {}

    public static final String SESSION_KEY = "CONSENT_VERSION";

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public Boolean hasAgreed(String userId, String version) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT 1 FROM MEMBER_CONSENT WHERE user_id = ? AND policy_version = ?");
            pstmt.setString(1, userId);
            pstmt.setString(2, version);
            rs = pstmt.executeQuery();
            return rs.next() ? Boolean.TRUE : Boolean.FALSE;
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    public boolean agree(String userId, String version) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("INSERT IGNORE INTO MEMBER_CONSENT (user_id, policy_version) VALUES (?, ?)");
            pstmt.setString(1, userId);
            pstmt.setString(2, version);
            pstmt.executeUpdate();
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}
