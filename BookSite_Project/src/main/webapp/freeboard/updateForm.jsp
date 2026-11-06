<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil" %>
<%@ page import="board.BoardDAO, board.BoardVO, upload.BoardFileDAO, upload.BoardFileVO, java.util.List" %>

<%
    request.setCharacterEncoding("UTF-8");
    String numStr = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");

    // 글 번호는 숫자만, pageNum도 숫자만 허용 (문자가 오면 500 에러 / 스크립트 삽입 방지)
    if (numStr == null || !numStr.trim().matches("\\d{1,9}")) {
        out.println("<script>alert('잘못된 접근입니다.'); history.go(-1);</script>");
        return;
    }
    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";

    int num = Integer.parseInt(numStr.trim());
    BoardDAO dao = BoardDAO.getInstance();
    BoardVO board = dao.getBoardDetail(num);
    if (board == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='list.jsp';</script>");
        return;
    }
    List<BoardFileVO> existingFiles = BoardFileDAO.getInstance().getFiles(num);

    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");

    // 작성자 본인 또는 관리자만 가능 (작성자 정보가 없는 예전 글은 관리자만)
    boolean isOwnerOrAdmin = sessionUserId != null
            && (sessionUserId.equals(board.getWriterId()) || "ADMIN".equals(sessionRole));
    if (!isOwnerOrAdmin) {
        out.println("<script>alert('수정 권한이 없습니다.'); history.go(-1);</script>");
        return;
    }
    String editorHtml = util.RichText.isHtml(board.getContent())
            ? util.RichText.sanitize(util.RichText.body(board.getContent()))
            : util.RichText.legacyToHtml(board.getContent(), existingFiles, request.getContextPath());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>게시글 수정</title>
    <link rel="stylesheet" href="../css/freeboard/update.css">
    <link rel="stylesheet" href="../lib/summernote/summernote-lite.min.css">
    <link rel="stylesheet" href="../css/editor.css">
    <link rel="stylesheet" href="../css/mobile.css">
</head>
<body>

<div class="container">
    <h2>게시글 수정</h2>
    <form action="${pageContext.request.contextPath}/board/upload?_csrf=<%= util.CsrfUtil.token(session) %>" method="post" enctype="multipart/form-data"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
        <input type="hidden" name="num" value="<%= num %>">
        <input type="hidden" name="pageNum" value="<%= pageNum %>">
        <input type="hidden" name="category" value="<%= board.getCategory() %>">
        <input type="hidden" name="redirectBoard" value="freeboard">

        <div class="form-group">
            <label>제목</label>
            <input type="text" name="subject" value="<%= HtmlUtil.esc(board.getSubject()) %>" required>
        </div>

        <div class="form-group">
            <label>내용</label>
            <input type="hidden" name="contentFormat" value="html">
                <textarea id="editor" name="content" data-upload-url="${pageContext.request.contextPath}/board/editor-image" data-csrf="<%= util.CsrfUtil.token(session) %>" placeholder="내용을 입력해 주세요."><%= HtmlUtil.esc(editorHtml) %></textarea>
                <p class="editor-help">사진은 툴바의 🖼 버튼, 드래그, 붙여넣기(Ctrl+V)로 원하는 위치에 넣을 수 있어요. 넣은 사진을 클릭하면 크기(100/50/25%)와 정렬(왼쪽/오른쪽)을 바꿀 수 있고, 끌어서 옮길 수도 있어요.</p>
        </div>

        <%
            List<BoardFileVO> attachFiles = new java.util.ArrayList<BoardFileVO>();
            for (BoardFileVO f : existingFiles) if (!f.isImage()) attachFiles.add(f);
            if (!attachFiles.isEmpty()) { %>
        <div class="form-group">
            <label>기존 첨부파일 (사진은 본문 에디터에서 관리)</label>
            <p style="font-size: 13px; color: #666; margin: 0;">
                <% for (int i = 0; i < attachFiles.size(); i++) {
                       BoardFileVO f = attachFiles.get(i); %>
                    <%= f.isVideo() ? "🎬" : "📎" %> <%= HtmlUtil.esc(f.getOriginalName()) %><%= i < attachFiles.size() - 1 ? ", " : "" %>
                <% } %>
            </p>
        </div>
        <% } %>

        <div class="form-group">
            <label>동영상 / 파일 추가 첨부</label>
            <input type="file" name="files" accept="image/*,video/*,.hwp,.hwpx,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" multiple>
        </div>

        <div class="btn-box">
            <button type="submit" class="btn btn-submit">수정 완료</button>
            <button type="button" class="btn btn-cancel" onclick="location.href='content.jsp?num=<%= num %>&pageNum=<%= pageNum %>'">취소</button>
        </div>
    </form>
</div>

<script src="../lib/jquery/jquery.min.js"></script>
<script src="../lib/summernote/summernote-lite.min.js"></script>
<script src="../lib/summernote/lang/summernote-ko-KR.min.js"></script>
<script src="../js/editor.js"></script>
</body>
</html>