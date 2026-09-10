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

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/mysql");
        return ds.getConnection();
    }

    // 게시글 등록
    public void insertBoard(BoardVO board) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO BOARD (board_type, category, writer_id, writer_nickname, subject, content) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, board.getBoardType());
            pstmt.setString(2, board.getCategory());
            pstmt.setString(3, board.getWriterId());
            pstmt.setString(4, board.getWriterNickname());
            pstmt.setString(5, board.getSubject());
            pstmt.setString(6, board.getContent());
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 게시글 삭제
    public void deleteBoard(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("DELETE FROM BOARD WHERE num = ?");
            pstmt.setInt(1, num);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 개수 조회
    public int getBoardCount(String boardType, String category) {
        int x = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM BOARD WHERE board_type = ?";
            if ("popular".equals(category)) {
                sql += " AND readcount >= 50";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, boardType);
            } else if (category != null && !category.equals("all")) {
                sql += " AND category = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, boardType);
                pstmt.setString(2, category);
            } else {
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, boardType);
            }

            rs = pstmt.executeQuery();
            if (rs.next()) x = rs.getInt(1);
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return x;
    }

    // 목록 조회
    public List<BoardVO> getBoards(String boardType, String category, int startRow, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardVO> list = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM BOARD WHERE board_type = ?";
            
            if ("popular".equals(category)) {
                sql += " AND readcount >= 50 ORDER BY num DESC LIMIT ?, ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, boardType);
                pstmt.setInt(2, startRow);
                pstmt.setInt(3, pageSize);
            } else if (category != null && !category.equals("all")) {
                sql += " AND category = ? ORDER BY num DESC LIMIT ?, ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, boardType);
                pstmt.setString(2, category);
                pstmt.setInt(3, startRow);
                pstmt.setInt(4, pageSize);
            } else {
                sql += " ORDER BY num DESC LIMIT ?, ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, boardType);
                pstmt.setInt(2, startRow);
                pstmt.setInt(3, pageSize);
            }

            rs = pstmt.executeQuery();
            if (rs.next()) {
                list = new ArrayList<>();
                do {
                    BoardVO vo = new BoardVO();
                    vo.setNum(rs.getInt("num"));
                    vo.setBoardType(rs.getString("board_type"));
                    vo.setCategory(rs.getString("category"));
                    vo.setWriterId(rs.getString("writer_id"));
                    vo.setWriterNickname(rs.getString("writer_nickname"));
                    vo.setSubject(rs.getString("subject"));
                    vo.setContent(rs.getString("content"));
                    vo.setReadcount(rs.getInt("readcount"));
                    vo.setLikeCount(rs.getInt("like_count"));
                    vo.setRegDate(rs.getTimestamp("reg_date"));
                    list.add(vo);
                } while (rs.next());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return list;
    }

    // 조회수 증가
    public void updateReadcount(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("UPDATE BOARD SET readcount = readcount + 1 WHERE num = ?");
            pstmt.setInt(1, num);
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    // 상세 조회
    public BoardVO getBoardDetail(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BoardVO vo = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT * FROM BOARD WHERE num = ?");
            pstmt.setInt(1, num);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vo = new BoardVO();
                vo.setNum(rs.getInt("num"));
                vo.setBoardType(rs.getString("board_type"));
                vo.setCategory(rs.getString("category"));
                vo.setWriterId(rs.getString("writer_id"));
                vo.setWriterNickname(rs.getString("writer_nickname"));
                vo.setSubject(rs.getString("subject"));
                vo.setContent(rs.getString("content"));
                vo.setReadcount(rs.getInt("readcount"));
                vo.setLikeCount(rs.getInt("like_count"));
                vo.setRegDate(rs.getTimestamp("reg_date"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return vo;
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}