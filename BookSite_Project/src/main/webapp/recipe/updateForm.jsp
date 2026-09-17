<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String numStr = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");

    if (numStr == null || numStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.go(-1);</script>");
        return;
    }

    int num = Integer.parseInt(numStr);
    BoardDAO dao = BoardDAO.getInstance();
    BoardVO board = dao.getBoardDetail(num);

    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");

    boolean isOwnerOrAdmin = (sessionUserId != null && (sessionUserId.equals(board.getWriterId()) || "ADMIN".equals(sessionRole))) || (board.getWriterId() == null);
    if (!isOwnerOrAdmin) {
        out.println("<script>alert('수정 권한이 없습니다.'); history.go(-1);</script>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>레시피 수정 - 자취의 품격</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Pretendard', 'Malgun Gothic', sans-serif; background-color: #f7f9fa; }
        .container { max-width: 700px; margin: 40px auto; padding: 0 20px; }
        .card { background: white; padding: 30px; border-radius: 12px; border: 1px solid #eaeaea; box-shadow: 0 2px 10px rgba(0,0,0,0.03); }
        h2 { font-size: 20px; font-weight: 800; color: #1e272e; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; margin-bottom: 22px; }
        .form-group { margin-bottom: 18px; }
        label { display: block; font-weight: 700; font-size: 14px; color: #2d3436; margin-bottom: 8px; }
        input[type="text"], textarea {
            width: 100%; padding: 12px 15px; border: 1px solid #e1e4e8; border-radius: 8px;
            font-size: 14px; outline: none; font-family: inherit; transition: border-color 0.2s;
        }
        input[type="text"]:focus, textarea:focus { border-color: #4caf50; }
        textarea { resize: vertical; min-height: 260px; line-height: 1.6; }
        .btn-box { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
        .btn { padding: 11px 24px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 700; }
        .btn-submit { background-color: #4caf50; color: white; }
        .btn-submit:hover { background-color: #388e3c; }
        .btn-cancel { background-color: #edf2f7; color: #4a5568; }
        .btn-cancel:hover { background-color: #e2e8f0; }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h2>🍳 레시피 수정</h2>
        <form action="updatePro.jsp" method="post">
            <input type="hidden" name="num" value="<%= num %>">
            <input type="hidden" name="pageNum" value="<%= pageNum %>">

            <div class="form-group">
                <label>요리 이름</label>
                <input type="text" name="subject" value="<%= board.getSubject() %>" required>
            </div>

            <div class="form-group">
                <label>재료 &amp; 만드는 법</label>
                <textarea name="content" required><%= board.getContent() %></textarea>
            </div>

            <div class="btn-box">
                <button type="button" class="btn btn-cancel" onclick="location.href='content.jsp?num=<%= num %>&pageNum=<%= pageNum %>'">취소</button>
                <button type="submit" class="btn btn-submit">수정 완료</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>
