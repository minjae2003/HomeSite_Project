package upload;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class BoardFileDAO {
    private static BoardFileDAO instance = new BoardFileDAO();
    public static BoardFileDAO getInstance() { return instance; }
    private BoardFileDAO() {}

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public void insertFile(BoardFileVO file) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO BOARD_FILE (board_num, original_name, saved_name, file_type, file_size, upload_order, reg_date) " +
                         "VALUES (?, ?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, file.getBoardNum());
            pstmt.setString(2, file.getOriginalName());
            pstmt.setString(3, file.getSavedName());
            pstmt.setString(4, file.getFileType());
            pstmt.setLong(5, file.getFileSize());
            pstmt.setInt(6, file.getUploadOrder());
            pstmt.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
    }

    public List<BoardFileVO> getFiles(int boardNum) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BoardFileVO> list = new ArrayList<BoardFileVO>();

        try {
            conn = getConnection();
            String sql = "SELECT * FROM BOARD_FILE WHERE board_num = ? ORDER BY upload_order ASC, file_num ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, boardNum);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BoardFileVO file = new BoardFileVO();
                file.setFileNum(rs.getInt("file_num"));
                file.setBoardNum(rs.getInt("board_num"));
                file.setOriginalName(rs.getString("original_name"));
                file.setSavedName(rs.getString("saved_name"));
                file.setFileType(rs.getString("file_type"));
                file.setFileSize(rs.getLong("file_size"));
                file.setUploadOrder(rs.getInt("upload_order"));
                file.setRegDate(rs.getTimestamp("reg_date"));
                list.add(file);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return list;
    }

    public void deleteFile(int fileNum) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "DELETE FROM BOARD_FILE WHERE file_num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, fileNum);
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
