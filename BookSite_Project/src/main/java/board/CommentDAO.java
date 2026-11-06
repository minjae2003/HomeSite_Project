package board;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class CommentDAO {
    private static CommentDAO instance = new CommentDAO();
    public static CommentDAO getInstance() { return instance; }
    private CommentDAO() {}

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public void insertComment(CommentVO comment) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO BOARD_COMMENT (board_num, writer, writer_id, writer_nickname, content, reg_date) VALUES (?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, comment.getBoardNum());
            pstmt.setString(2, comment.getWriter());
            pstmt.setString(3, comment.getWriterId());
            pstmt.setString(4, comment.getWriterNickname());
            pstmt.setString(5, comment.getContent());
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
            return;
        } finally {
            close(conn, pstmt, null);
        }
        notification.NotificationDAO.getInstance()
        .notifyComment(comment.getBoardNum(), comment.getWriterId(), comment.getWriterNickname(), comment.getContent());
    }

    public List<CommentVO> getComments(int boardNum) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<CommentVO> list = new ArrayList<CommentVO>();

        try {
            conn = getConnection();
            String sql = "SELECT * FROM BOARD_COMMENT WHERE board_num = ? ORDER BY comment_num ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, boardNum);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CommentVO vo = new CommentVO();
                vo.setCommentNum(rs.getInt("comment_num"));
                vo.setBoardNum(rs.getInt("board_num"));
                vo.setWriter(rs.getString("writer"));
                vo.setWriterId(rs.getString("writer_id"));
                vo.setWriterNickname(rs.getString("writer_nickname"));
                vo.setContent(rs.getString("content"));
                vo.setRegDate(rs.getTimestamp("reg_date"));
                list.add(vo);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return list;
    }

    public void deleteComment(int commentNum) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "DELETE FROM BOARD_COMMENT WHERE comment_num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentNum);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }
    /**
     * 댓글 삭제 - 작성자 본인 또는 관리자만 가능
     * @return 실제로 삭제됐으면 true (권한 없음/없는 댓글이면 false)
     */
    public boolean deleteComment(int commentNum, int boardNum, String userId, boolean isAdmin) {
        if (userId == null) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = isAdmin
                ? "DELETE FROM BOARD_COMMENT WHERE comment_num = ? AND board_num = ?"
                : "DELETE FROM BOARD_COMMENT WHERE comment_num = ? AND board_num = ? AND writer_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentNum);
            pstmt.setInt(2, boardNum);
            if (!isAdmin) pstmt.setString(3, userId);
            return pstmt.executeUpdate() == 1;   // 0이면 남의 댓글이거나 없는 댓글
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }
    /**
     * 댓글 수정 - 작성자 본인 또는 관리자만 가능
     * @return 실제로 수정됐으면 true (권한 없음/없는 댓글이면 false)
     */
    public boolean updateComment(int commentNum, int boardNum, String userId, boolean isAdmin, String content) {
        if (userId == null) return false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = isAdmin
                ? "UPDATE BOARD_COMMENT SET content = ? WHERE comment_num = ? AND board_num = ?"
                : "UPDATE BOARD_COMMENT SET content = ? WHERE comment_num = ? AND board_num = ? AND writer_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, content);
            pstmt.setInt(2, commentNum);
            pstmt.setInt(3, boardNum);
            if (!isAdmin) pstmt.setString(4, userId);
            return pstmt.executeUpdate() == 1;
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