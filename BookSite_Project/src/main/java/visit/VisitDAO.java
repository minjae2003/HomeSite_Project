package visit;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.ZoneId;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/** 방문자 기록: 하루(한국 시간)에 세션당 1건. 실제 기록은 VisitServlet이 사람으로 판단한 경우에만 */
public class VisitDAO {
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    private static VisitDAO instance = new VisitDAO();
    public static VisitDAO getInstance() { return instance; }
    private VisitDAO() {}

    /** 오늘 날짜 (서버 시간대와 상관없이 한국 기준, 자정에 바뀜) */
    public static String today() {
        return LocalDate.now(KST).toString();
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public void recordVisit(String sessionId) {
        if (sessionId == null || sessionId.trim().isEmpty()) return;
        String today = today();
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("INSERT IGNORE INTO VISIT_LOG (visit_date, session_id) VALUES (?, ?)")) {
                ps.setString(1, today);
                ps.setString(2, sessionId);
                ps.executeUpdate();
            }
            if (java.util.concurrent.ThreadLocalRandom.current().nextInt(500) == 0) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM VISIT_LOG WHERE visit_date < ? LIMIT 5000")) {
                    ps.setString(1, LocalDate.now(KST).minusYears(1).toString());
                    ps.executeUpdate();
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public int getTodayVisitorCount() {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM VISIT_LOG WHERE visit_date = ?")) {
            ps.setString(1, today());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return 0;
        }
    }
}
