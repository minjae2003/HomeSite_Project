package qna;

import java.sql.*;
import java.util.*;
import javax.naming.*;
import javax.sql.DataSource;
import java.util.List;
import java.util.ArrayList;

public class QnaDAO {
    private static QnaDAO instance = new QnaDAO();
    public static QnaDAO getInstance() { return instance; }
    private QnaDAO() {}

    private Connection getConnection() throws Exception {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/basicjsp");
        return ds.getConnection();
    }

    // 게시글 등록 (원글 및 답변글)
    public void insertQna(QnaDTO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        int num = article.getNum();
        int ref = article.getRef();
        int re_step = article.getRe_step();
        int re_level = article.getRe_level();
        int number = 0;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT MAX(num) FROM qna");
            rs = pstmt.executeQuery();

            if (rs.next()) number = rs.getInt(1) + 1;
            else number = 1;

            if (num != 0) { // 답변글인 경우
                String sql = "UPDATE qna SET re_step=re_step+1 WHERE ref=? AND re_step > ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, ref);
                pstmt.setInt(2, re_step);
                pstmt.executeUpdate();
                re_step = re_step + 1;
                re_level = re_level + 1;
            } else { // 새 원글인 경우
                ref = number;
                re_step = 0;
                re_level = 0;
            }

            String sql = "INSERT INTO qna(writer, subject, content, reg_date, ref, re_step, re_level, secret) VALUES(?,?,?,NOW(),?,?,?,?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, article.getWriter());
            pstmt.setString(2, article.getSubject());
            pstmt.setString(3, article.getContent());
            pstmt.setInt(4, ref);
            pstmt.setInt(5, re_step);
            pstmt.setInt(6, re_level);
            pstmt.setString(7, article.getSecret() == null ? "N" : article.getSecret());
            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }

    // 전체 글 개수 조회
    public int getQnaCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT COUNT(*) FROM qna");
            rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        return count;
    }

    // 글 목록 가져오기
    public List<QnaDTO> getQnaList(int start, int count) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<QnaDTO> list = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM qna ORDER BY ref DESC, re_step ASC LIMIT ?, ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start - 1);
            pstmt.setInt(2, count);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                list = new ArrayList<>();
                do {
                    QnaDTO article = new QnaDTO();
                    article.setNum(rs.getInt("num"));
                    article.setWriter(rs.getString("writer"));
                    article.setSubject(rs.getString("subject"));
                    article.setReg_date(rs.getTimestamp("reg_date"));
                    article.setReadcount(rs.getInt("readcount"));
                    article.setRef(rs.getInt("ref"));
                    article.setRe_step(rs.getInt("re_step"));
                    article.setRe_level(rs.getInt("re_level"));
                    article.setSecret(rs.getString("secret"));
                    list.add(article);
                } while (rs.next());
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        return list;
    }

    // 글 상세 정보 가져오기
    public QnaDTO getQna(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        QnaDTO article = null;

        try {
            conn = getConnection();
            
            // 조회수 증가
            pstmt = conn.prepareStatement("UPDATE qna SET readcount=readcount+1 WHERE num=?");
            pstmt.setInt(1, num);
            pstmt.executeUpdate();

            // 데이터 상세 조회
            pstmt = conn.prepareStatement("SELECT * FROM qna WHERE num=?");
            pstmt.setInt(1, num);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                article = new QnaDTO();
                article.setNum(rs.getInt("num"));
                article.setWriter(rs.getString("writer"));
                article.setSubject(rs.getString("subject"));
                article.setContent(rs.getString("content"));
                article.setReg_date(rs.getTimestamp("reg_date"));
                article.setReadcount(rs.getInt("readcount"));
                article.setRef(rs.getInt("ref"));
                article.setRe_step(rs.getInt("re_step"));
                article.setRe_level(rs.getInt("re_level"));
                article.setSecret(rs.getString("secret"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        return article;
    }
 // 1. 조회수 증가 메서드
    public void updateReadCount(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection(); // 기존 QnaDAO의 커넥션 획득 메서드명 사용
            String sql = "UPDATE qna SET readcount = readcount + 1 WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }

    // 2. 게시글 상세 조회 메서드
    public QnaDTO getQnaArticle(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        QnaDTO article = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM qna WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                article = new QnaDTO();
                article.setNum(rs.getInt("num"));
                article.setWriter(rs.getString("writer"));
                article.setSubject(rs.getString("subject"));
                article.setContent(rs.getString("content"));
                article.setReg_date(rs.getTimestamp("reg_date"));
                article.setReadcount(rs.getInt("readcount"));
                article.setRef(rs.getInt("ref"));
                article.setRe_step(rs.getInt("re_step"));
                article.setRe_level(rs.getInt("re_level"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }

        return article;
    }
    public int updateQnaArticle(QnaDTO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            conn = getConnection();
            String sql = "UPDATE qna SET subject = ?, content = ? WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, article.getSubject());
            pstmt.setString(2, article.getContent());
            pstmt.setInt(3, article.getNum());
            
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }

        return result;
    }
 // 1. 게시글 삭제
    public int deleteQnaArticle(int num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            conn = getConnection();
            String sql = "DELETE FROM qna WHERE num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return result;
    }

    // 2. 댓글 등록
    public void insertQnaComment(int num, String writer, String content) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO qna_comment(num, writer, content, reg_date) VALUES(?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            pstmt.setString(2, writer);
            pstmt.setString(3, content);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
 // 댓글 목록 가져오기
    public List<QnaCommentDTO> getQnaComments(int num) {
        List<QnaCommentDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM qna_comment WHERE num = ? ORDER BY c_num ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, num);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                QnaCommentDTO comment = new QnaCommentDTO();
                comment.setC_num(rs.getInt("c_num"));
                comment.setNum(rs.getInt("num"));
                comment.setWriter(rs.getString("writer"));
                comment.setContent(rs.getString("content"));
                comment.setReg_date(rs.getTimestamp("reg_date"));
                list.add(comment);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }
 // 댓글 삭제 메서드
    public int deleteQnaComment(int c_num) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            conn = getConnection();
            String sql = "DELETE FROM qna_comment WHERE c_num = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, c_num);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return result;
    }
 // 1. 전체 게시글 수 조회 메서드
    public int getArticleCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM qna";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return count;
    }

    // 2. 페이징 처리된 게시글 목록 조회 메서드
    public List<QnaDTO> getArticles(int currentPage, int pageSize) {
        List<QnaDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 시작 행 위치 계산 (MySQL LIMIT 구문 기준)
        int startRow = (currentPage - 1) * pageSize;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM qna ORDER BY num DESC LIMIT ?, ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, startRow);
            pstmt.setInt(2, pageSize);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                QnaDTO article = new QnaDTO();
                article.setNum(rs.getInt("num"));
                article.setWriter(rs.getString("writer"));
                article.setSubject(rs.getString("subject"));
                article.setContent(rs.getString("content"));
                article.setReg_date(rs.getTimestamp("reg_date"));
                article.setReadcount(rs.getInt("readcount"));
                article.setRef(rs.getInt("ref"));
                article.setRe_step(rs.getInt("re_step"));
                article.setRe_level(rs.getInt("re_level"));
                list.add(article);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }
    private void close(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
    }
 // QnaDAO.java 클래스 내부 적절한 위치에 추가
    public void insertArticle(QnaDTO article) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "INSERT INTO qna(writer, subject, content, reg_date, readcount, ref, re_step, re_level, secret) VALUES(?, ?, ?, NOW(), 0, 0, 0, 0, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, article.getWriter());
            pstmt.setString(2, article.getSubject());
            pstmt.setString(3, article.getContent());
            pstmt.setString(4, article.getSecret());
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 기존 DAO에서 사용하는 자원 해제(close) 메서드명에 맞춰 수정
            close(null, pstmt, conn); 
        }
    }
}