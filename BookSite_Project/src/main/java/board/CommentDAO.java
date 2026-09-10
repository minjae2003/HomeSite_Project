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

    // 1. 댓글 등록
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
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 2. 댓글 목록 조회
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

    // 3. 댓글 삭제
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

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}