<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, upload.BoardFileDAO, upload.BoardFileVO, java.util.List" %>

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
    List<BoardFileVO> existingFiles = BoardFileDAO.getInstance().getFiles(num);

    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");

    boolean isOwnerOrAdmin = (sessionUserId != null && (sessionUserId.equals(board.getWriterId()) || "ADMIN".equals(sessionRole))) || (board.getWriterId() == null);
    if (!isOwnerOrAdmin) {
        out.println("<script>alert('수정 권한이 없습니다.'); history.go(-1);</script>");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 수정</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 30px; background-color: #f9f9f9; }
        .container { max-width: 700px; margin: 0 auto; background: white; padding: 25px; border-radius: 8px; border: 1px solid #ddd; }
        h2 { border-bottom: 2px solid #007bff; padding-bottom: 10px; margin-top: 0; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input[type="text"], textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .btn-box { text-align: right; margin-top: 15px; }
        .btn { padding: 8px 18px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; }
        .btn-submit { background-color: #007bff; color: white; }
        .btn-cancel { background-color: #6c757d; color: white; }
    </style>
</head>
<body>

<div class="container">
    <h2>게시글 수정</h2>
    <form action="${pageContext.request.contextPath}/board/upload" method="post" enctype="multipart/form-data">
        <input type="hidden" name="num" value="<%= num %>">
        <input type="hidden" name="pageNum" value="<%= pageNum %>">
        <input type="hidden" name="category" value="<%= board.getCategory() %>">
        <input type="hidden" name="redirectBoard" value="freeboard">

        <div class="form-group">
            <label>제목</label>
            <input type="text" name="subject" value="<%= board.getSubject() %>" required>
        </div>

        <div class="form-group">
            <label>내용 <small style="font-weight:normal;color:#888;">([img1], [video1]... 로 사진/동영상 위치 지정)</small></label>
            <textarea name="content" rows="12" required><%= board.getContent() %></textarea>
        </div>

        <% if (!existingFiles.isEmpty()) { %>
        <div class="form-group">
            <label>기존 첨부파일</label>
            <p style="font-size: 13px; color: #666; margin: 0;">
                <% for (int i = 0; i < existingFiles.size(); i++) {
                       BoardFileVO f = existingFiles.get(i); %>
                    <%= f.isImage() ? "🖼" : "🎬" %> <%= f.getOriginalName() %><%= i < existingFiles.size() - 1 ? ", " : "" %>
                <% } %>
            </p>
        </div>
        <% } %>

        <div class="form-group">
            <label>사진 / 동영상 추가 첨부</label>
            <input type="file" name="files" accept="image/*,video/*" multiple>
        </div>

        <div class="btn-box">
            <button type="submit" class="btn btn-submit">수정 완료</button>
            <button type="button" class="btn btn-cancel" onclick="location.href='content.jsp?num=<%= num %>&pageNum=<%= pageNum %>'">취소</button>
        </div>
    </form>
</div>

</body>
</html>