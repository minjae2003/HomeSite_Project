package notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/**
 * 알림 저장/조회/설정
 * - 알림 생성은 CommentDAO(댓글), BoardDAO(추천, 공지 등록)에서 호출한다.
 * - 받는 사람이 해당 종류의 알림을 꺼 두었으면(NOTIFICATION_SETTING) 생성하지 않는다.
 * - 알림 처리 중 오류가 나도 원래 작업(댓글 등록 등)에는 영향을 주지 않도록 예외는 여기서 처리한다.
 */
public class NotificationDAO {
    private static NotificationDAO instance = new NotificationDAO();
    public static NotificationDAO getInstance() { return instance; }
    private NotificationDAO() {}

    public static final String[] TYPES = { "COMMENT", "LIKE", "NOTICE" };

    public static boolean isValidType(String type) {
        for (String t : TYPES) if (t.equals(type)) return true;
        return false;
    }

    /** 알림 종류 → 설정 테이블 컬럼 이름 (화이트리스트) */
    private static String settingColumn(String type) {
        if ("COMMENT".equals(type)) return "comment_on";
        if ("LIKE".equals(type)) return "like_on";
        if ("NOTICE".equals(type)) return "notice_on";
        return null;
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public void notifyComment(int boardNum, String actorId, String actorNickname, String commentContent) {
        String sql = "INSERT INTO NOTIFICATION (receiver_id, type, actor_id, actor_nickname, board_num, board_subject, preview) "
                   + "SELECT b.writer_id, 'COMMENT', ?, ?, b.num, b.subject, ? FROM BOARD b "
                   + "WHERE b.num = ? AND b.writer_id IS NOT NULL AND b.writer_id <> ? "
                   + "AND NOT EXISTS (SELECT 1 FROM NOTIFICATION_SETTING s WHERE s.user_id = b.writer_id AND s.comment_on = 'N')";
        execute(sql, actorId, actorNickname, makePreview(commentContent), boardNum, actorId);
    }

    /**
     * 내 글이 추천을 받았을 때 → 글 작성자에게 알림
     * 추천/취소를 반복해도 같은 사람의 같은 글 추천 알림은 한 번만 생기도록 중복을 막는다.
     */
    public void notifyLike(int boardNum, String actorId, String actorNickname) {
        String sql = "INSERT INTO NOTIFICATION (receiver_id, type, actor_id, actor_nickname, board_num, board_subject) "
                   + "SELECT b.writer_id, 'LIKE', ?, COALESCE(?, (SELECT m.nickname FROM MEMBER m WHERE m.id = ?)), b.num, b.subject "
                   + "FROM BOARD b "
                   + "WHERE b.num = ? AND b.writer_id IS NOT NULL AND b.writer_id <> ? "
                   + "AND NOT EXISTS (SELECT 1 FROM NOTIFICATION n "
                   + "                WHERE n.type = 'LIKE' AND n.board_num = b.num AND n.actor_id = ?) "
                   + "AND NOT EXISTS (SELECT 1 FROM NOTIFICATION_SETTING s WHERE s.user_id = b.writer_id AND s.like_on = 'N')";
        execute(sql, actorId, actorNickname, actorId, boardNum, actorId, actorId);
    }

    public void notifyNotice(int boardNum, String actorId, String actorNickname, String noticeContent) {
        String sql = "INSERT INTO NOTIFICATION (receiver_id, type, actor_id, actor_nickname, board_num, board_subject, preview) "
                   + "SELECT m.id, 'NOTICE', ?, ?, b.num, b.subject, ? FROM MEMBER m JOIN BOARD b ON b.num = ? "
                   + "WHERE m.id <> ? "
                   + "AND NOT EXISTS (SELECT 1 FROM NOTIFICATION_SETTING s WHERE s.user_id = m.id AND s.notice_on = 'N')";
        execute(sql, actorId, actorNickname, makePreview(noticeContent), boardNum, actorId == null ? "" : actorId);
    }

    private static String makePreview(String content) {
        if (content == null) return null;
        String p = content.replaceAll("\\[(img|video)\\d+\\]", " ").replaceAll("\\s+", " ").trim();
        if (p.isEmpty()) return null;
        return p.length() > 100 ? p.substring(0, 100) : p;
    }

    public int getUnreadCount(String userId) {
        return getUnreadCount(userId, null);
    }

    public int getUnreadCount(String userId, String type) {
        if (userId == null) return 0;
        boolean byType = isValidType(type);
        String sql = "SELECT COUNT(*) FROM NOTIFICATION WHERE receiver_id = ? AND is_read = 'N'"
                   + (byType ? " AND type = ?" : "");
        return byType ? queryInt(sql, userId, type) : queryInt(sql, userId);
    }

    public int getCount(String userId, String type) {
        if (userId == null) return 0;
        boolean byType = isValidType(type);
        String sql = "SELECT COUNT(*) FROM NOTIFICATION WHERE receiver_id = ?" + (byType ? " AND type = ?" : "");
        return byType ? queryInt(sql, userId, type) : queryInt(sql, userId);
    }

    public List<NotificationVO> getList(String userId, int start, int count) {
        return getList(userId, null, start, count);
    }

    public List<NotificationVO> getList(String userId, String type, int start, int count) {
        List<NotificationVO> list = new ArrayList<NotificationVO>();
        if (userId == null) return list;
        boolean byType = isValidType(type);
        String sql = "SELECT n.*, b.board_type FROM NOTIFICATION n LEFT JOIN BOARD b ON b.num = n.board_num "
                   + "WHERE n.receiver_id = ?" + (byType ? " AND n.type = ?" : "")
                   + " ORDER BY n.noti_num DESC LIMIT ?, ?";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            pstmt.setString(idx++, userId);
            if (byType) pstmt.setString(idx++, type);
            pstmt.setInt(idx++, start);
            pstmt.setInt(idx, count);
            rs = pstmt.executeQuery();
            while (rs.next()) list.add(toVO(rs));
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return list;
    }

    /** 알림 1건 조회 (본인 알림만) */
    public NotificationVO get(int notiNum, String userId) {
        if (userId == null) return null;
        String sql = "SELECT n.*, b.board_type FROM NOTIFICATION n LEFT JOIN BOARD b ON b.num = n.board_num "
                   + "WHERE n.noti_num = ? AND n.receiver_id = ?";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, notiNum);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) return toVO(rs);
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return null;
    }

    private NotificationVO toVO(ResultSet rs) throws Exception {
        NotificationVO vo = new NotificationVO();
        vo.setNotiNum(rs.getInt("noti_num"));
        vo.setReceiverId(rs.getString("receiver_id"));
        vo.setType(rs.getString("type"));
        vo.setActorId(rs.getString("actor_id"));
        vo.setActorNickname(rs.getString("actor_nickname"));
        vo.setBoardNum(rs.getInt("board_num"));
        vo.setBoardSubject(rs.getString("board_subject"));
        vo.setPreview(rs.getString("preview"));
        vo.setBoardType(rs.getString("board_type"));
        vo.setRead("Y".equals(rs.getString("is_read")));
        vo.setRegDate(rs.getTimestamp("reg_date"));
        return vo;
    }

    /** 알림 1건 읽음 처리 (본인 알림만) */
    public void markRead(int notiNum, String userId) {
        execute("UPDATE NOTIFICATION SET is_read = 'Y' WHERE noti_num = ? AND receiver_id = ?", notiNum, userId);
    }

    public void markAllRead(String userId) {
        execute("UPDATE NOTIFICATION SET is_read = 'Y' WHERE receiver_id = ? AND is_read = 'N'", userId);
    }

    /** 알림 1건 삭제 (본인 알림만) */
    public void delete(int notiNum, String userId) {
        execute("DELETE FROM NOTIFICATION WHERE noti_num = ? AND receiver_id = ?", notiNum, userId);
    }

    public boolean[] getSettings(String userId) {
        boolean[] on = { true, true, true };
        if (userId == null) return on;
        String sql = "SELECT comment_on, like_on, notice_on FROM NOTIFICATION_SETTING WHERE user_id = ?";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                on[0] = !"N".equals(rs.getString(1));
                on[1] = !"N".equals(rs.getString(2));
                on[2] = !"N".equals(rs.getString(3));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return on;
    }

    public void setSetting(String userId, String type, boolean on) {
        String col = settingColumn(type);
        if (userId == null || col == null) return;
        String sql = "INSERT INTO NOTIFICATION_SETTING (user_id, " + col + ") VALUES (?, ?) "
                   + "ON DUPLICATE KEY UPDATE " + col + " = VALUES(" + col + ")";
        execute(sql, userId, on ? "Y" : "N");
    }

    private int queryInt(String sql, String... params) {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) pstmt.setString(i + 1, params[i]);
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return 0;
    }

    private void execute(String sql, Object... params) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                Object p = params[i];
                if (p instanceof Integer) pstmt.setInt(i + 1, (Integer) p);
                else pstmt.setString(i + 1, p == null ? null : p.toString());
            }
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
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