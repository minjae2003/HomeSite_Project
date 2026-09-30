package mypage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

import board.BoardVO;

/**
 * 마이페이지 전용 조회
 *  - 활동 통계(작성글/댓글/받은 추천/추천한 글), 카테고리별 작성 수
 *  - 탭별 목록: 내가 쓴 글 / 댓글 단 글 / 추천한 글
 *  - 계정에 저장된 체크리스트 진행률
 */
public class MyPageDAO {
    private static MyPageDAO instance = new MyPageDAO();
    public static MyPageDAO getInstance() { return instance; }
    private MyPageDAO() {}

    public static final String TAB_POSTS = "posts";
    public static final String TAB_COMMENTS = "comments";
    public static final String TAB_LIKES = "likes";

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    // ───────────────────────── 통계 ─────────────────────────

    /** 한 개의 숫자를 돌려주는 쿼리 공통 처리 */
    private int queryInt(String sql, String userId) {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return 0;
    }

    public int getPostCount(String userId) {
        return queryInt("SELECT COUNT(*) FROM BOARD WHERE writer_id = ?", userId);
    }

    public int getCommentCount(String userId) {
        return queryInt("SELECT COUNT(*) FROM BOARD_COMMENT WHERE writer_id = ?", userId);
    }

    /** 내 글들이 받은 추천 합계 */
    public int getReceivedLikeCount(String userId) {
        return queryInt("SELECT IFNULL(SUM(like_count), 0) FROM BOARD WHERE writer_id = ?", userId);
    }

    /** 내가 추천한 글 수 */
    public int getLikedCount(String userId) {
        return queryInt("SELECT COUNT(*) FROM BOARD_LIKE l JOIN BOARD b ON b.num = l.board_num WHERE l.user_id = ?", userId);
    }

    /** 댓글 단 글 수 (같은 글에 여러 번 달아도 1개) */
    public int getCommentedPostCount(String userId) {
        return queryInt("SELECT COUNT(DISTINCT board_num) FROM BOARD_COMMENT WHERE writer_id = ?", userId);
    }

    /** 내 글 중 가장 많이 받은 추천 수 (뱃지 계산용) */
    public int getMaxLike(String userId) {
        return queryInt("SELECT IFNULL(MAX(like_count), 0) FROM BOARD WHERE writer_id = ?", userId);
    }

    /** 카테고리(board_type)별 내 작성 글 수 (뱃지 계산용) */
    public Map<String, Integer> getPostCountByCategory(String userId) {
        Map<String, Integer> map = new LinkedHashMap<String, Integer>();
        String sql = "SELECT board_type, COUNT(*) FROM BOARD WHERE writer_id = ? GROUP BY board_type";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) map.put(rs.getString(1), rs.getInt(2));
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return map;
    }

    /** 계정에 저장된 체크리스트 진행률 {체크 수, 전체 수}, 저장 기록이 없으면 null */
    public int[] getChecklistProgress(String userId) {
        String sql = "SELECT CHECKED_CNT, TOTAL_CNT FROM USER_CHECKLIST WHERE USER_ID = ?";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) return new int[] { rs.getInt(1), rs.getInt(2) };
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return null;
    }

    // ───────────────────────── 탭 목록 ─────────────────────────

    /** 탭별 전체 개수 (페이징용) */
    public int getTabCount(String tab, String userId) {
        if (TAB_COMMENTS.equals(tab)) return getCommentedPostCount(userId);
        if (TAB_LIKES.equals(tab)) return getLikedCount(userId);
        return getPostCount(userId);
    }

    /** 탭별 목록 (내가 쓴 글 / 댓글 단 글 / 추천한 글) */
    public List<BoardVO> getTabList(String tab, String userId, int start, int count) {
        String cols = "b.num, b.subject, b.board_type, b.readcount, b.like_count, b.reg_date, "
                    + "(SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.board_num = b.num) AS comment_count";
        String sql;
        if (TAB_COMMENTS.equals(tab)) {
            // 댓글 단 글: 내가 가장 최근에 댓글 단 순서
            sql = "SELECT " + cols + " FROM BOARD b JOIN ("
                + "  SELECT board_num, MAX(comment_num) AS last_comment FROM BOARD_COMMENT"
                + "  WHERE writer_id = ? GROUP BY board_num) mc ON mc.board_num = b.num "
                + "ORDER BY mc.last_comment DESC LIMIT ?, ?";
        } else if (TAB_LIKES.equals(tab)) {
            // 추천한 글: 최근에 추천한 순서
            sql = "SELECT " + cols + " FROM BOARD b JOIN BOARD_LIKE l ON l.board_num = b.num "
                + "WHERE l.user_id = ? ORDER BY l.reg_date DESC, b.num DESC LIMIT ?, ?";
        } else {
            sql = "SELECT " + cols + " FROM BOARD b WHERE b.writer_id = ? ORDER BY b.num DESC LIMIT ?, ?";
        }

        List<BoardVO> list = new ArrayList<BoardVO>();
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, start);
            pstmt.setInt(3, count);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BoardVO vo = new BoardVO();
                vo.setNum(rs.getInt("num"));
                vo.setSubject(rs.getString("subject"));
                vo.setCategory(rs.getString("board_type"));
                vo.setReadcount(rs.getInt("readcount"));
                vo.setLikeCount(rs.getInt("like_count"));
                vo.setRegDate(rs.getTimestamp("reg_date"));
                vo.setCommentCount(rs.getInt("comment_count"));
                list.add(vo);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return list;
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}
