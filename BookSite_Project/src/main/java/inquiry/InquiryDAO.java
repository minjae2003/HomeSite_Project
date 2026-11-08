package inquiry;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class InquiryDAO {
    private static final InquiryDAO instance = new InquiryDAO();
    public static InquiryDAO getInstance() { return instance; }
    private InquiryDAO() {}

    public static final String[][] CATEGORIES = {
        { "USE", "이용 문의" },
        { "BUG", "오류 신고" },
        { "REPORT", "게시물·회원 신고" },
        { "ACCOUNT", "계정·개인정보" },
        { "ETC", "기타" }
    };

    public static boolean isValidCategory(String code) {
        for (String[] c : CATEGORIES) if (c[0].equals(code)) return true;
        return false;
    }

    public static String categoryName(String code) {
        for (String[] c : CATEGORIES) if (c[0].equals(code)) return c[1];
        return "기타";
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public int insert(InquiryVO vo) {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "INSERT INTO INQUIRY (user_id, category, subject, content, page_url) VALUES (?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, vo.getUserId());
            pstmt.setString(2, vo.getCategory());
            pstmt.setString(3, vo.getSubject());
            pstmt.setString(4, vo.getContent());
            pstmt.setString(5, vo.getPageUrl());
            pstmt.executeUpdate();
            rs = pstmt.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return 0;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    public int countRecent(String userId, int minutes) {
        return queryInt("SELECT COUNT(*) FROM INQUIRY WHERE user_id = ? AND reg_date >= NOW() - INTERVAL " + minutes + " MINUTE",
                        userId);
    }

    public List<InquiryVO> listByUser(String userId, int limit) {
        return list("SELECT i.*, m.nickname FROM INQUIRY i LEFT JOIN MEMBER m ON m.id = i.user_id "
                  + "WHERE i.user_id = ? ORDER BY i.inquiry_num DESC LIMIT " + limit, userId);
    }

    public List<InquiryVO> listAll(String status, int start, int count) {
        boolean byStatus = "WAIT".equals(status) || "DONE".equals(status);
        String sql = "SELECT i.*, m.nickname FROM INQUIRY i LEFT JOIN MEMBER m ON m.id = i.user_id"
                   + (byStatus ? " WHERE i.status = '" + status + "'" : "")
                   + " ORDER BY (i.status = 'WAIT') DESC, i.inquiry_num DESC LIMIT " + Math.max(0, start) + ", " + count;
        return list(sql);
    }

    public int countAll(String status) {
        boolean byStatus = "WAIT".equals(status) || "DONE".equals(status);
        return byStatus ? queryInt("SELECT COUNT(*) FROM INQUIRY WHERE status = ?", status)
                        : queryInt("SELECT COUNT(*) FROM INQUIRY");
    }

    public InquiryVO get(int inquiryNum) {
        List<InquiryVO> l = list("SELECT i.*, m.nickname FROM INQUIRY i LEFT JOIN MEMBER m ON m.id = i.user_id "
                               + "WHERE i.inquiry_num = ?", inquiryNum);
        return l.isEmpty() ? null : l.get(0);
    }

    public boolean answer(int inquiryNum, String adminId, String answer) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "UPDATE INQUIRY SET answer = ?, answered_by = ?, answered_at = NOW(), status = 'DONE' WHERE inquiry_num = ?");
            pstmt.setString(1, answer);
            pstmt.setString(2, adminId);
            pstmt.setInt(3, inquiryNum);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    public boolean deleteOwn(int inquiryNum, String userId) {
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("DELETE FROM INQUIRY WHERE inquiry_num = ? AND user_id = ? AND status = 'WAIT'");
            pstmt.setInt(1, inquiryNum);
            pstmt.setString(2, userId);
            return pstmt.executeUpdate() == 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        } finally {
            close(conn, pstmt, null);
        }
    }

    private List<InquiryVO> list(String sql, Object... params) {
        List<InquiryVO> list = new ArrayList<InquiryVO>();
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) pstmt.setObject(i + 1, params[i]);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                InquiryVO vo = new InquiryVO();
                vo.setInquiryNum(rs.getInt("inquiry_num"));
                vo.setUserId(rs.getString("user_id"));
                vo.setUserNickname(rs.getString("nickname"));
                vo.setCategory(rs.getString("category"));
                vo.setSubject(rs.getString("subject"));
                vo.setContent(rs.getString("content"));
                vo.setPageUrl(rs.getString("page_url"));
                vo.setStatus(rs.getString("status"));
                vo.setAnswer(rs.getString("answer"));
                vo.setAnsweredBy(rs.getString("answered_by"));
                vo.setAnsweredAt(rs.getTimestamp("answered_at"));
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

    private int queryInt(String sql, Object... params) {
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) pstmt.setObject(i + 1, params[i]);
            rs = pstmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return -1;
        } finally {
            close(conn, pstmt, rs);
        }
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}
