<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DatabaseMetaData" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>DB 연결 테스트</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; line-height: 1.6; }
        .box { padding: 20px; border-radius: 8px; margin-top: 15px; }
        .success { background-color: #e8f5e9; border: 1px solid #4caf50; color: #2e7d32; }
        .error { background-color: #ffebee; border: 1px solid #ef5350; color: #c62828; }
        ul { margin: 10px 0; padding-left: 20px; }
        code { background: #f4f4f4; padding: 3px 6px; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <h2>🔍 MySQL DB (homesiteproject) 연결 테스트</h2>

    <%
        Connection conn = null;
        try {
            Context initCtx = new InitialContext();
            Context envCtx = (Context) initCtx.lookup("java:comp/env");
            DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
            
            conn = ds.getConnection();
            DatabaseMetaData meta = conn.getMetaData();
    %>
        <div class="box success">
            <h3>✅ DB 연결에 성공했습니다!</h3>
            <ul>
                <li><b>DB 제품명:</b> <%= meta.getDatabaseProductName() %> (<%= meta.getDatabaseProductVersion() %>)</li>
                <li><b>JDBC 드라이버:</b> <%= meta.getDriverName() %> (<%= meta.getDriverVersion() %>)</li>
                <li><b>연결 URL:</b> <%= meta.getURL() %></li>
                <li><b>접속 계정:</b> <%= meta.getUserName() %></li>
            </ul>
            <p>이제 회원가입, 로그인 및 게시판 기능이 DB와 정상 연동됩니다.</p>
        </div>
    <%
        } catch (Exception e) {
    %>
        <div class="box error">
            <h3>❌ DB 연결 실패</h3>
            <p><b>오류 메시지:</b> <code><%= e.getMessage() %></code></p>
            <hr>
            <b>오류 원인별 조치법:</b>
            <ul>
                <li><b>Access denied:</b> <code>context.xml</code>에 작성한 <code>homesiteproject</code> 비밀번호를 다시 확인하세요.</li>
                <li><b>NameNotFoundException:</b> <code>context.xml</code> 파일이 <code>META-INF</code> 폴더 안에 있는지 확인하세요.</li>
                <li><b>Unknown database:</b> MySQL에 <code>homesiteproject</code> 데이터베이스가 생성되어 있는지 확인하세요.</li>
            </ul>
        </div>
    <%
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    %>
</body>
</html>