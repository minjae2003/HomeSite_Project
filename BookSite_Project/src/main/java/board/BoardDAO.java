package board;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class BoardDAO {
    private static BoardDAO instance = new BoardDAO();
    public static BoardDAO getInstance() { return instance; }
    private BoardDAO() {}

    // DBCP 커넥션 풀 연결
    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    // 1. 카테고리별 게시글 수 조회
    public int getArticleCount(String category) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM BOARD";
            if (category != null && !category.isEmpty() && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category)) {
                sql += " WHERE board_type = ?";
            }
            pstmt = conn.prepareStatement(sql);
            if (category != null && !category.isEmpty() && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category)) {
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

    // 2. 카테고리별 목록 조회
 // 2. 카테고리별 목록 조회 (댓글 수 조회 서브쿼리 추가)
    public List<BoardVO> getArticles(int start, int count, String category) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> articleList = null;

        try {
            conn = getConnection();
            
            // 댓글 수(comment_count) 서브쿼리 추가
            String sql = "SELECT b.*, (SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.board_num = b.num) AS comment_count FROM BOARD b";
            if (category != null && !category.isEmpty() && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category)) {
                sql += " WHERE b.board_type = ?";
            }
            
            if ("BEST".equalsIgnoreCase(category)) {
                sql += " ORDER BY b.readcount DESC, b.num DESC LIMIT ?, ?";
            } else {
                sql += " ORDER BY b.num DESC LIMIT ?, ?";
            }

            pstmt = conn.prepareStatement(sql);
            int paramIdx = 1;
            if (category != null && !category.isEmpty() && !"ALL".equalsIgnoreCase(category) && !"BEST".equalsIgnoreCase(category)) {
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
                    try { article.setCommentCount(rs.getInt("comment_count")); } catch (Exception e) {} // 댓글 수 매핑

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

    // 3. 게시글 작성
    public void insertArticle(BoardVO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO BOARD (writer, writer_id, writer_nickname, subject, content, readcount, reg_date, board_type) VALUES (?, ?, ?, ?, ?, 0, NOW(), ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, article.getWriter());
            pstmt.setString(2, article.getWriterId());
            pstmt.setString(3, article.getWriterNickname());
            pstmt.setString(4, article.getSubject());
            pstmt.setString(5, article.getContent());
            pstmt.setString(6, article.getCategory() != null ? article.getCategory() : "FREE");
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 4. 조회수 증가
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

    // 5. 게시글 상세 조회
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
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return board;
    }

    // 6. 특정 사용자가 추천했는지 확인
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

    // 7. 추천/추천취소 토글
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
        return isLikedNow;
    }

    // 8. 게시글 수정
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

    // 9. 게시글 삭제
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

    // 10. 자원 해제
    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}