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
    <title>공지사항 작성 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/noticeboard/write.css">
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
            <h1 class="form-title">📢 공지사항 작성</h1>
            <p class="form-subtitle">회원들에게 전달할 안내 사항을 작성해 주세요.</p>
        </div>

        <form action="${pageContext.request.contextPath}/board/upload" method="post" enctype="multipart/form-data">
            <input type="hidden" name="redirectBoard" value="noticeboard">
            <div class="form-group">
                <label class="form-label">공지 유형</label>
                <% if ("ADMIN".equals(sessionRole)) { %>
                <div class="category-select-group">
                    <label>
                        <input type="radio" name="noticeType" value="NORMAL" checked>
                        <span class="cat-btn">📝 일반공지</span>
                    </label>
                    <label>
                        <input type="radio" name="noticeType" value="FIX">
                        <span class="cat-btn">📌 고정공지</span>
                    </label>
                </div>
                <% } else { %>
                <input type="hidden" name="noticeType" value="NORMAL">
                <span style="font-size: 13px; color: #888;">📝 일반공지로 등록됩니다. (고정공지는 관리자만 등록 가능)</span>
                <% } %>
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
                <textarea name="content" class="input-control" placeholder="공지 내용을 작성해 주세요.&#10;&#10;사진/동영상을 넣고 싶은 위치에 [img1], [video1] 처럼 적어두면 그 자리에 삽입됩니다." required></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">사진 / 동영상 첨부</label>
                <input type="file" name="files" class="input-control" accept="image/*,video/*,.hwp,.hwpx,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar,.7z" multiple>
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