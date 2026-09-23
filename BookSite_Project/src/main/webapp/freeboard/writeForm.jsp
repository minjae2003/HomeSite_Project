<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");

    // 로그인하지 않은 사용자는 글쓰기 폼에 접근할 수 없도록 차단
    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");
    if (sessionUserNick == null) sessionUserNick = sessionUserId;
    if (sessionUserNick == null) sessionUserNick = "익명";

    String sessionRole = (String) session.getAttribute("role");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>글쓰기 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/freeboard/write.css">
</head>
<body>

<nav class="navbar">
    <div class="nav-container">
        <a href="list.jsp" class="logo">
            <span class="logo-icon">🏠</span> 자취의 품격
        </a>
    </div>
</nav>

<div class="container">
    <div class="card">
        <div class="form-header">
            <h1 class="form-title">✏️ 커뮤니티 글쓰기</h1>
            <p class="form-subtitle">자취에 관한 소소한 이야기부터 꿀팁, 질문을 공유해 보세요.</p>
        </div>

        <form action="${pageContext.request.contextPath}/board/upload" method="post" enctype="multipart/form-data">
            <input type="hidden" name="redirectBoard" value="freeboard">
            <div class="form-group">
                <label class="form-label">카테고리 선택</label>
                <div class="category-select-group">
                    <label>
                        <input type="radio" name="category" value="FREE" checked>
                        <span class="cat-btn">🏫 일상/수다</span>
                    </label>
                    <label>
                        <input type="radio" name="category" value="TIP">
                        <span class="cat-btn">💡 자취꿀팁</span>
                    </label>
                    <label>
                        <input type="radio" name="category" value="QNA">
                        <span class="cat-btn">❓ 질문/답변</span>
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
                <input type="text" class="input-control input-readonly" value="<%= sessionUserNick %>" readonly>
            </div>

            <div class="form-group">
                <label class="form-label">제목</label>
                <input type="text" name="subject" class="input-control" placeholder="제목을 입력해 주세요." required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label">내용</label>
                <textarea name="content" class="input-control" placeholder="자취생들과 나누고 싶은 이야기를 자유롭게 작성해 주세요.&#10;&#10;사진/동영상을 넣고 싶은 위치에 [img1], [img2], [video1] 처럼 적어두면 그 자리에 삽입됩니다. (안 적으면 글 맨 아래에 순서대로 첨부돼요)" required></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">사진 / 동영상 첨부</label>
                <input type="file" name="files" class="input-control" accept="image/*,video/*,.hwp,.hwpx,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" multiple>
                <p class="form-subtitle" style="margin-top: 6px;">여러 개 선택 가능 (이미지/동영상 + 한글(.hwp)/PDF/워드/엑셀/압축파일 등) · 본문에 [img1], [img2]... [video1], [video2]... 순서로 적어 사진·동영상은 원하는 위치에 넣을 수 있어요. 그 외 문서 파일은 본문 아래 첨부파일 목록에 자동으로 붙습니다.</p>
            </div>

            <div class="btn-group">
                <button type="button" class="btn btn-cancel" onclick="location.href='list.jsp'">취소</button>
                <button type="submit" class="btn btn-submit">게시글 등록</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>