package board;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class BoardDAO {
    private static BoardDAO instance = new BoardDAO();
    public static BoardDAO getInstance() { return instance; }
    private BoardDAO() {}

    public static final int HOT_WINDOW_HOURS = 24;
    private static final int W_VIEW = 1, W_LIKE = 5, W_COMMENT = 3;

    private static final String HOT_JOINS =
          " LEFT JOIN (SELECT board_num, COUNT(*) AS cnt FROM BOARD_VIEW_LOG"
        + "   WHERE viewed_at >= NOW() - INTERVAL " + HOT_WINDOW_HOURS + " HOUR GROUP BY board_num) hv ON hv.board_num = b.num"
        + " LEFT JOIN (SELECT board_num, COUNT(*) AS cnt FROM BOARD_LIKE"
        + "   WHERE reg_date >= NOW() - INTERVAL " + HOT_WINDOW_HOURS + " HOUR GROUP BY board_num) hl ON hl.board_num = b.num"
        + " LEFT JOIN (SELECT board_num, COUNT(*) AS cnt FROM BOARD_COMMENT"
        + "   WHERE reg_date >= NOW() - INTERVAL " + HOT_WINDOW_HOURS + " HOUR GROUP BY board_num) hc ON hc.board_num = b.num";
    private static final String HOT_SCORE =
        "(COALESCE(hv.cnt, 0) * " + W_VIEW + " + COALESCE(hl.cnt, 0) * " + W_LIKE + " + COALESCE(hc.cnt, 0) * " + W_COMMENT + ")";
    private static final String HOT_ORDER =
        " ORDER BY (" + HOT_SCORE + " > 0) DESC, " + HOT_SCORE + " DESC, b.readcount DESC, b.num DESC LIMIT ?, ?";

    private static boolean isBest(String category) {
        return "BEST".equalsIgnoreCase(category) || "FREE_BEST".equalsIgnoreCase(category);
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public int getArticleCount(String category) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM BOARD";
            boolean freeboardScoped = "FREE_ALL".equalsIgnoreCase(category) || "FREE_BEST".equalsIgnoreCase(category);
            boolean filter = category != null && !category.isEmpty() && !freeboardScoped
                    && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category);

            if (filter) {
                sql += " WHERE board_type = ?";
            } else if (freeboardScoped) {
                sql += " WHERE board_type IN ('FREE', 'TIP', 'QNA', 'RECIPE')";
            } else {
                sql += " WHERE board_type <> 'NOTICE'";
            }

            pstmt = conn.prepareStatement(sql);
            if (filter) {
                pstmt.setString(1, category);
            }
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
    public int getArticleCount(String category, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getArticleCount(category);
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM BOARD";
            boolean freeboardScoped = "FREE_ALL".equalsIgnoreCase(category) || "FREE_BEST".equalsIgnoreCase(category);
            boolean filter = category != null && !category.isEmpty() && !freeboardScoped
                    && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category);

            if (filter) {
                sql += " WHERE board_type = ? AND (subject LIKE ? OR content LIKE ?)";
            } else if (freeboardScoped) {
                sql += " WHERE board_type IN ('FREE', 'TIP', 'QNA', 'RECIPE') AND (subject LIKE ? OR content LIKE ?)";
            } else {
                sql += " WHERE board_type <> 'NOTICE' AND (subject LIKE ? OR content LIKE ?)";
            }

            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            if (filter) {
                pstmt.setString(idx++, category);
            }
            String likeword = "%" + keyword.trim() + "%";
            pstmt.setString(idx++, likeword);
            pstmt.setString(idx++, likeword);
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

    public List<BoardVO> getArticles(int start, int count, String category) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> articleList = null;

        try {
            conn = getConnection();

            String sql = "SELECT b.*, (SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.board_num = b.num) AS comment_count FROM BOARD b"
                    + (isBest(category) ? HOT_JOINS : "");
            boolean freeboardScoped = "FREE_ALL".equalsIgnoreCase(category) || "FREE_BEST".equalsIgnoreCase(category);
            boolean filter = category != null && !category.isEmpty() && !freeboardScoped
                    && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category);

            if (filter) {
                sql += " WHERE b.board_type = ?";
            } else if (freeboardScoped) {
                sql += " WHERE b.board_type IN ('FREE', 'TIP', 'QNA', 'RECIPE')";
            } else {
                sql += " WHERE b.board_type <> 'NOTICE'";
            }

            if (isBest(category)) {
                sql += HOT_ORDER;
            } else {
                sql += " ORDER BY (b.category = 'FIX') DESC, b.num DESC LIMIT ?, ?";
            }

            pstmt = conn.prepareStatement(sql);
            int paramIdx = 1;
            if (filter) {
                pstmt.setString(paramIdx++, category);
            }
            pstmt.setInt(paramIdx++, start);
            pstmt.setInt(paramIdx++, count);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                articleList = new ArrayList<BoardVO>();
                do {
                    BoardVO article = new BoardVO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setContent(rs.getString("content"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setRegDate(rs.getTimestamp("reg_date"));

                    try { article.setWriterId(rs.getString("writer_id")); } catch (Exception e) {}
                    try { article.setWriterNickname(rs.getString("writer_nickname")); } catch (Exception e) {}
                    try { article.setLikeCount(rs.getInt("like_count")); } catch (Exception e) {}
                    try { article.setCategory(rs.getString("board_type")); } catch (Exception e) {}
                    try { article.setNoticeType(rs.getString("category")); } catch (Exception e) {}
                    try { article.setCommentCount(rs.getInt("comment_count")); } catch (Exception e) {}

                    articleList.add(article);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return articleList;
    }
    public List<BoardVO> getArticles(int start, int count, String category, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getArticles(start, count, category);
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> articleList = null;

        try {
            conn = getConnection();

            String sql = "SELECT b.*, (SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.board_num = b.num) AS comment_count FROM BOARD b"
                    + (isBest(category) ? HOT_JOINS : "");
            boolean freeboardScoped = "FREE_ALL".equalsIgnoreCase(category) || "FREE_BEST".equalsIgnoreCase(category);
            boolean filter = category != null && !category.isEmpty() && !freeboardScoped
                    && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category);

            if (filter) {
                sql += " WHERE b.board_type = ? AND (b.subject LIKE ? OR b.content LIKE ?)";
            } else if (freeboardScoped) {
                sql += " WHERE b.board_type IN ('FREE', 'TIP', 'QNA', 'RECIPE') AND (b.subject LIKE ? OR b.content LIKE ?)";
            } else {
                sql += " WHERE b.board_type <> 'NOTICE' AND (b.subject LIKE ? OR b.content LIKE ?)";
            }

            if (isBest(category)) {
                sql += HOT_ORDER;
            } else {
                sql += " ORDER BY (b.category = 'FIX') DESC, b.num DESC LIMIT ?, ?";
            }

            pstmt = conn.prepareStatement(sql);
            int paramIdx = 1;
            if (filter) {
                pstmt.setString(paramIdx++, category);
            }
            String likeword = "%" + keyword.trim() + "%";
            pstmt.setString(paramIdx++, likeword);
            pstmt.setString(paramIdx++, likeword);
            pstmt.setInt(paramIdx++, start);
            pstmt.setInt(paramIdx++, count);

            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                articleList = new ArrayList<BoardVO>();
                do {
                    BoardVO article = new BoardVO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setContent(rs.getString("content"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setRegDate(rs.getTimestamp("reg_date"));

                    try { article.setWriterId(rs.getString("writer_id")); } catch (Exception e) {}
                    try { article.setWriterNickname(rs.getString("writer_nickname")); } catch (Exception e) {}
                    try { article.setLikeCount(rs.getInt("like_count")); } catch (Exception e) {}
                    try { article.setCategory(rs.getString("board_type")); } catch (Exception e) {}
                    try { article.setNoticeType(rs.getString("category")); } catch (Exception e) {}
                    try { article.setCommentCount(rs.getInt("comment_count")); } catch (Exception e) {}

                    articleList.add(article);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return articleList;
    }
    public int insertArticle(BoardVO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedNum = 0;

        try {
            conn = getConnection();
            String sql = "INSERT INTO BOARD (writer, writer_id, writer_nickname, subject, content, readcount, reg_date, board_type) VALUES (?, ?, ?, ?, ?, 0, NOW(), ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, article.getWriter());
            pstmt.setString(2, article.getWriterId());
            pstmt.setString(3, article.getWriterNickname());
            pstmt.setString(4, article.getSubject());
            pstmt.setString(5, article.getContent());
            pstmt.setString(6, article.getCategory() != null ? article.getCategory() : "FREE");
            pstmt.executeUpdate();

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                generatedNum = rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return generatedNum;
    }

    public void updateReadcount(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "UPDATE BOARD SET readcount = readcount + 1 WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    public void logView(int boardNum, String viewerKey) {
        if (viewerKey == null || viewerKey.isEmpty()) return;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT 1 FROM BOARD_VIEW_LOG WHERE board_num = ? AND viewer_key = ?"
                    + " AND viewed_at >= NOW() - INTERVAL " + HOT_WINDOW_HOURS + " HOUR LIMIT 1");
            pstmt.setInt(1, boardNum);
            pstmt.setString(2, viewerKey);
            rs = pstmt.executeQuery();
            boolean already = rs.next();
            rs.close(); rs = null;
            pstmt.close(); pstmt = null;
            if (!already) {
                pstmt = conn.prepareStatement("INSERT INTO BOARD_VIEW_LOG (board_num, viewer_key) VALUES (?, ?)");
                pstmt.setInt(1, boardNum);
                pstmt.setString(2, viewerKey);
                pstmt.executeUpdate();
                pstmt.close(); pstmt = null;
            }
            if (java.util.concurrent.ThreadLocalRandom.current().nextInt(200) == 0) {
                pstmt = conn.prepareStatement("DELETE FROM BOARD_VIEW_LOG WHERE viewed_at < NOW() - INTERVAL 7 DAY LIMIT 1000");
                pstmt.executeUpdate();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
    }

    public BoardVO getBoardDetail(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BoardVO board = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM BOARD WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                board = new BoardVO();
                board.setNum(rs.getInt("num"));
                board.setWriter(rs.getString("writer"));
                board.setSubject(rs.getString("subject"));
                board.setContent(rs.getString("content"));
                board.setReadcount(rs.getInt("readcount"));
                board.setRegDate(rs.getTimestamp("reg_date"));

                try { board.setWriterId(rs.getString("writer_id")); } catch (Exception e) {}
                try { board.setWriterNickname(rs.getString("writer_nickname")); } catch (Exception e) {}
                try { board.setLikeCount(rs.getInt("like_count")); } catch (Exception e) {}
                try { board.setCategory(rs.getString("board_type")); } catch (Exception e) {}
                try { board.setNoticeType(rs.getString("category")); } catch (Exception e) {}
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return board;
    }

    public boolean hasUserLiked(int boardNum, String userId) {
        if (userId == null || userId.trim().isEmpty()) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean liked = false;

        try {
            conn = getConnection();
            String sql = "SELECT 1 FROM BOARD_LIKE WHERE board_num = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, boardNum);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                liked = true;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return liked;
    }

    public boolean toggleLike(int boardNum, String userId) {
        if (userId == null || userId.trim().isEmpty()) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean isLikedNow = false;

        try {
            conn = getConnection();
            boolean alreadyLiked = hasUserLiked(boardNum, userId);

            if (alreadyLiked) {
                String delSql = "DELETE FROM BOARD_LIKE WHERE board_num = ? AND user_id = ?";
                pstmt = conn.prepareStatement(delSql);
                pstmt.setInt(1, boardNum);
                pstmt.setString(2, userId);
                pstmt.executeUpdate();
                pstmt.close();

                String updateSql = "UPDATE BOARD SET like_count = GREATEST(0, IFNULL(like_count, 0) - 1) WHERE num = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, boardNum);
                pstmt.executeUpdate();

                isLikedNow = false;
            } else {
                String insSql = "INSERT INTO BOARD_LIKE (board_num, user_id) VALUES (?, ?)";
                pstmt = conn.prepareStatement(insSql);
                pstmt.setInt(1, boardNum);
                pstmt.setString(2, userId);
                pstmt.executeUpdate();
                pstmt.close();

                String updateSql = "UPDATE BOARD SET like_count = IFNULL(like_count, 0) + 1 WHERE num = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, boardNum);
                pstmt.executeUpdate();

                isLikedNow = true;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
        if (isLikedNow) {
            notification.NotificationDAO.getInstance().notifyLike(boardNum, userId, null);
        }
        return isLikedNow;
    }

    public void updateArticle(BoardVO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "UPDATE BOARD SET subject = ?, content = ?, board_type = ? WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, article.getSubject());
            pstmt.setString(2, article.getContent());
            pstmt.setString(3, article.getCategory() != null ? article.getCategory() : "FREE");
            pstmt.setInt(4, article.getNum());
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    public List<BoardVO> getSitemapArticles(int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> list = new ArrayList<BoardVO>();
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT num, board_type, reg_date FROM BOARD ORDER BY num DESC LIMIT ?");
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BoardVO a = new BoardVO();
                a.setNum(rs.getInt("num"));
                a.setCategory(rs.getString("board_type"));
                a.setRegDate(rs.getTimestamp("reg_date"));
                list.add(a);
            }
            return list;
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    public boolean setPinned(int num, boolean pinned) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("UPDATE BOARD SET category = ? WHERE num = ? AND board_type <> 'NOTICE'");
            pstmt.setString(1, pinned ? "FIX" : "FREE");
            pstmt.setInt(2, num);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    public void deleteArticle(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "DELETE FROM BOARD WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    public int getNoticeCount(String noticeType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM BOARD WHERE board_type = 'NOTICE'";
            boolean filter = noticeType != null && !noticeType.isEmpty() && !"ALL".equalsIgnoreCase(noticeType);
            if (filter) sql += " AND category = ?";

            pstmt = conn.prepareStatement(sql);
            if (filter) pstmt.setString(1, noticeType);

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

    public int getNoticeCount(String noticeType, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getNoticeCount(noticeType);
        }
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM BOARD WHERE board_type = 'NOTICE' AND (subject LIKE ? OR content LIKE ?)";
            boolean filter = noticeType != null && !noticeType.isEmpty() && !"ALL".equalsIgnoreCase(noticeType);
            if (filter) sql += " AND category = ?";

            pstmt = conn.prepareStatement(sql);
            String likeword = "%" + keyword.trim() + "%";
            pstmt.setString(1, likeword);
            pstmt.setString(2, likeword);
            if (filter) pstmt.setString(3, noticeType);

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
    public List<BoardVO> getNotices(int start, int count, String noticeType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> articleList = null;

        try {
            conn = getConnection();
            String sql = "SELECT b.*, (SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.board_num = b.num) AS comment_count " +
                         "FROM BOARD b WHERE b.board_type = 'NOTICE'";
            boolean filter = noticeType != null && !noticeType.isEmpty() && !"ALL".equalsIgnoreCase(noticeType);
            if (filter) sql += " AND b.category = ?";

            sql += " ORDER BY CASE WHEN b.category = 'FIX' THEN 0 ELSE 1 END, b.num DESC LIMIT ?, ?";

            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            if (filter) pstmt.setString(idx++, noticeType);
            pstmt.setInt(idx++, start);
            pstmt.setInt(idx++, count);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                articleList = new ArrayList<BoardVO>();
                do {
                    BoardVO article = new BoardVO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setContent(rs.getString("content"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setRegDate(rs.getTimestamp("reg_date"));

                    try { article.setWriterId(rs.getString("writer_id")); } catch (Exception e) {}
                    try { article.setWriterNickname(rs.getString("writer_nickname")); } catch (Exception e) {}
                    try { article.setLikeCount(rs.getInt("like_count")); } catch (Exception e) {}
                    try { article.setNoticeType(rs.getString("category")); } catch (Exception e) {}
                    try { article.setCommentCount(rs.getInt("comment_count")); } catch (Exception e) {}

                    articleList.add(article);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return articleList;
    }

    public List<BoardVO> getNotices(int start, int count, String noticeType, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getNotices(start, count, noticeType);
        }
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> articleList = null;

        try {
            conn = getConnection();
            String sql = "SELECT b.*, (SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.board_num = b.num) AS comment_count " +
                         "FROM BOARD b WHERE b.board_type = 'NOTICE' AND (b.subject LIKE ? OR b.content LIKE ?)";
            boolean filter = noticeType != null && !noticeType.isEmpty() && !"ALL".equalsIgnoreCase(noticeType);
            if (filter) sql += " AND b.category = ?";

            sql += " ORDER BY CASE WHEN b.category = 'FIX' THEN 0 ELSE 1 END, b.num DESC LIMIT ?, ?";

            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            String likeword = "%" + keyword.trim() + "%";
            pstmt.setString(idx++, likeword);
            pstmt.setString(idx++, likeword);
            if (filter) pstmt.setString(idx++, noticeType);
            pstmt.setInt(idx++, start);
            pstmt.setInt(idx++, count);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                articleList = new ArrayList<BoardVO>();
                do {
                    BoardVO article = new BoardVO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setContent(rs.getString("content"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setRegDate(rs.getTimestamp("reg_date"));

                    try { article.setWriterId(rs.getString("writer_id")); } catch (Exception e) {}
                    try { article.setWriterNickname(rs.getString("writer_nickname")); } catch (Exception e) {}
                    try { article.setLikeCount(rs.getInt("like_count")); } catch (Exception e) {}
                    try { article.setNoticeType(rs.getString("category")); } catch (Exception e) {}
                    try { article.setCommentCount(rs.getInt("comment_count")); } catch (Exception e) {}

                    articleList.add(article);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return articleList;
    }

    public int insertNotice(BoardVO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedNum = 0;

        try {
            conn = getConnection();
            String sql = "INSERT INTO BOARD (writer, writer_id, writer_nickname, subject, content, readcount, reg_date, board_type, category) " +
                         "VALUES (?, ?, ?, ?, ?, 0, NOW(), 'NOTICE', ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, article.getWriter());
            pstmt.setString(2, article.getWriterId());
            pstmt.setString(3, article.getWriterNickname());
            pstmt.setString(4, article.getSubject());
            pstmt.setString(5, article.getContent());
            pstmt.setString(6, article.getNoticeType() != null ? article.getNoticeType() : "NORMAL");
            pstmt.executeUpdate();

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                generatedNum = rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        if (generatedNum > 0) {
            notification.NotificationDAO.getInstance()
            .notifyNotice(generatedNum, article.getWriterId(), article.getWriterNickname(), util.RichText.toText(article.getContent()));
        }
        return generatedNum;
    }

    public void updateNotice(BoardVO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "UPDATE BOARD SET subject = ?, content = ?, category = ? WHERE num = ? AND board_type = 'NOTICE'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, article.getSubject());
            pstmt.setString(2, article.getContent());
            pstmt.setString(3, article.getNoticeType() != null ? article.getNoticeType() : "NORMAL");
            pstmt.setInt(4, article.getNum());
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