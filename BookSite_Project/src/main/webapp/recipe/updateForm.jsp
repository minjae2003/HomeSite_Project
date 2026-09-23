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
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>레시피 수정 - 자취의 품격</title>
   
    <link rel="stylesheet" href="../css/recipe/update.css">
</head>
<body>

<div class="container">
    <div class="card">
        <h2>🍳 레시피 수정</h2>
        <form action="${pageContext.request.contextPath}/board/upload" method="post" enctype="multipart/form-data">
            <input type="hidden" name="num" value="<%= num %>">
            <input type="hidden" name="pageNum" value="<%= pageNum %>">
            <input type="hidden" name="category" value="RECIPE">
            <input type="hidden" name="redirectBoard" value="recipe">

            <div class="form-group">
                <label>요리 이름</label>
                <input type="text" name="subject" value="<%= board.getSubject() %>" required>
            </div>

            <div class="form-group">
                <label>재료 &amp; 만드는 법 <small style="font-weight:normal;color:#888;">([img1], [video1]... 로 위치 지정)</small></label>
                <textarea name="content" required><%= board.getContent() %></textarea>
            </div>

            <% if (!existingFiles.isEmpty()) { %>
            <div class="form-group">
                <label>기존 첨부파일</label>
                <p style="font-size: 13px; color: #666; margin: 0;">
                    <% for (int i = 0; i < existingFiles.size(); i++) {
                           BoardFileVO f = existingFiles.get(i); %>
                        <%= f.isImage() ? "🖼" : (f.isVideo() ? "🎬" : "📎") %> <%= f.getOriginalName() %><%= i < existingFiles.size() - 1 ? ", " : "" %>
                    <% } %>
                </p>
            </div>
            <% } %>

            <div class="form-group">
                <label>사진 / 동영상 추가 첨부</label>
                <input type="file" name="files" accept="image/*,video/*,.hwp,.hwpx,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" multiple>
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
