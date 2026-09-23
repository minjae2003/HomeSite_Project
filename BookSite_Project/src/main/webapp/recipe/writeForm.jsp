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
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>레시피 등록 - 자취의 품격</title>
 
    <link rel="stylesheet" href="../css/recipe/write.css">
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
            <h1 class="form-title">🍳 레시피 등록</h1>
            <p class="form-subtitle">재료와 조리 순서를 적어서 나만의 자취 레시피를 공유해 보세요.</p>
        </div>

        <form action="${pageContext.request.contextPath}/board/upload" method="post" enctype="multipart/form-data">
            <input type="hidden" name="category" value="RECIPE">
            <input type="hidden" name="redirectBoard" value="recipe">

            <div class="form-group">
                <label class="form-label">작성자</label>
                <input type="text" class="input-control input-readonly" value="<%= sessionUserNick %>" readonly>
            </div>

            <div class="form-group">
                <label class="form-label">요리 이름</label>
                <input type="text" name="subject" class="input-control" placeholder="예) 5분 완성! 마늘 볶음밥" required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label">재료 &amp; 만드는 법</label>
                <textarea name="content" class="input-control" placeholder="[재료]&#10;예) 밥 1공기, 다진 마늘 1큰술, 계란 1개&#10;&#10;[만드는 법]&#10;1. ...&#10;2. (여기에 사진을 넣고 싶다면 [img1] 이렇게 적어주세요)&#10;3. ..." required></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">완성 사진 / 조리 동영상</label>
                <input type="file" name="files" class="input-control" accept="image/*,video/*,.hwp,.hwpx,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" multiple>
                <p class="form-subtitle" style="margin-top: 6px;">여러 장 선택 가능 (사진/동영상 + 한글(.hwp)/PDF 레시피 카드 등) · 본문에 [img1], [img2]... [video1]... 로 사진·동영상 위치를 지정할 수 있어요. 표시 안 하면 레시피 맨 아래에 자동으로 붙고, 문서 파일은 첨부파일 목록에 따로 표시됩니다.</p>
            </div>

            <div class="btn-group">
                <button type="button" class="btn btn-cancel" onclick="location.href='list.jsp'">취소</button>
                <button type="submit" class="btn btn-submit">레시피 등록</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>
