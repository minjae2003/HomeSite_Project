package visit;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class VisitDAO {
    private static VisitDAO instance = new VisitDAO();
    public static VisitDAO getInstance() { return instance; }
    private VisitDAO() {}

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    // 1. 오늘 방문 기록 (세션 1개당 하루 1번만 기록됨)
    public void recordVisit(String sessionId) {
        if (sessionId == null || sessionId.trim().isEmpty()) return;

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            // 이미 오늘 기록된 세션이면 조용히 무시 (중복 카운트 방지)
            String sql = "INSERT IGNORE INTO VISIT_LOG (visit_date, session_id) VALUES (CURDATE(), ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sessionId);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 2. 오늘 방문자 수 조회 (세션 기준 고유 방문자 수)
    public int getTodayVisitorCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM VISIT_LOG WHERE visit_date = CURDATE()";
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