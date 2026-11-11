<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");

    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");
    if (sessionUserNick == null) sessionUserNick = sessionUserId;
    if (sessionUserNick == null) sessionUserNick = "익명";

    String sessionRole = (String) session.getAttribute("role");

    String selCat = request.getParameter("category");
    selCat = (selCat == null) ? "FREE" : selCat.trim().toUpperCase();
    if (!java.util.Arrays.asList("FREE", "TIP", "QNA", "RECIPE").contains(selCat)) selCat = "FREE";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>글쓰기 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/freeboard/write.css">
    <link rel="stylesheet" href="../lib/summernote/summernote-lite.min.css">
    <link rel="stylesheet" href="../css/editor.css">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="container">
    <div class="card">
        <div class="form-header">
            <h1 class="form-title">✏️ 커뮤니티 글쓰기</h1>
            <p class="form-subtitle">자취에 관한 소소한 이야기부터 꿀팁, 질문, 요리레시피를 공유해 보세요.</p>
        </div>

        <form action="${pageContext.request.contextPath}/board/upload?_csrf=<%= util.CsrfUtil.token(session) %>" method="post" enctype="multipart/form-data"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
            <input type="hidden" name="redirectBoard" value="freeboard">
            <div class="form-group">
                <label class="form-label">카테고리 선택</label>
                <div class="category-select-group">
                    <label>
                        <input type="radio" name="category" value="FREE" <%= "FREE".equals(selCat) ? "checked" : "" %>>
                        <span class="cat-btn">🏫 일상/수다</span>
                    </label>
                    <label>
                        <input type="radio" name="category" value="TIP" <%= "TIP".equals(selCat) ? "checked" : "" %>>
                        <span class="cat-btn">💡 자취꿀팁</span>
                    </label>
                    <label>
                        <input type="radio" name="category" value="QNA" <%= "QNA".equals(selCat) ? "checked" : "" %>>
                        <span class="cat-btn">❓ 질문/답변</span>
                    </label>
                    <label>
                        <input type="radio" name="category" value="RECIPE" <%= "RECIPE".equals(selCat) ? "checked" : "" %>>
                        <span class="cat-btn">🍳 요리레시피</span>
                    </label>
                    <% if ("ADMIN".equals(sessionRole)) { %>
                    <label>
                        <input type="radio" name="category" value="NOTICE">
                        <span class="cat-btn">📢 공지사항</span>
                    </label>
                    <% } %>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">작성자</label>
                <input type="text" class="input-control input-readonly" value="<%= HtmlUtil.esc(sessionUserNick) %>" readonly>
            </div>

            <div class="form-group">
                <label class="form-label">제목</label>
                <input type="text" name="subject" class="input-control" placeholder="제목을 입력해 주세요." required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label">내용</label>
                <input type="hidden" name="contentFormat" value="html">
                <textarea id="editor" name="content" data-upload-url="${pageContext.request.contextPath}/board/editor-image" data-csrf="<%= util.CsrfUtil.token(session) %>" placeholder="자취생들과 나누고 싶은 이야기를 자유롭게 작성해 주세요."></textarea>
                <p class="editor-help">사진은 툴바의 🖼 버튼, 드래그, 붙여넣기(Ctrl+V)로 원하는 위치에 넣을 수 있어요. 넣은 사진을 클릭하면 크기(100/50/25%)와 정렬(왼쪽/오른쪽)을 바꿀 수 있고, 끌어서 옮길 수도 있어요.</p>
            </div>

            <div class="form-group">
                <label class="form-label">동영상 / 파일 첨부</label>
                <input type="file" name="files" class="input-control" accept="image/*,video/*,.hwp,.hwpx,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" multiple>
                <p class="form-subtitle" style="margin-top: 6px;">여러 개 선택 가능 · 동영상은 본문 아래에, 한글(.hwp)/PDF/워드/엑셀/압축파일 등은 첨부파일 목록에 붙어요. (여기서 고른 사진은 본문 맨 아래에 들어가요)</p>
            </div>

            <p class="post-notice">📌 전화번호·주소 등 개인정보, 욕설·비방, 광고·도배 글은 <a href="${pageContext.request.contextPath}/policy/rules.jsp" target="_blank" rel="noopener">운영정책</a>에 따라 숨김·삭제될 수 있어요. 다른 사람의 글이나 사진을 가져올 때는 출처를 밝혀 주세요.</p>

            <div class="btn-group">
                <button type="button" class="btn btn-cancel" onclick="location.href='list.jsp?category=<%= selCat %>'">취소</button>
                <button type="submit" class="btn btn-submit">게시글 등록</button>
            </div>
        </form>
    </div>
</div>

<script src="../lib/jquery/jquery.min.js"></script>
<script src="../lib/summernote/summernote-lite.min.js"></script>
<script src="../lib/summernote/lang/summernote-ko-KR.min.js"></script>
<script src="../js/editor.js"></script>
<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>