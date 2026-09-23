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
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Pretendard', 'Malgun Gothic', sans-serif; background-color: #f7f9fa; color: #333; line-height: 1.5; }
        a { text-decoration: none; color: inherit; }

        .navbar { background: #fff; border-bottom: 1px solid #eaeaea; padding: 15px 0; }
        .nav-container { max-width: 1000px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; }
        .logo { font-size: 20px; font-weight: 800; color: #4caf50; display: flex; align-items: center; gap: 8px; }
        .logo-icon { background: #4caf50; color: #fff; padding: 4px 8px; border-radius: 8px; font-size: 14px; }

        .container { max-width: 800px; margin: 40px auto; padding: 0 20px; }
        .card { background: #fff; border-radius: 12px; border: 1px solid #eaeaea; padding: 35px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); }

        .form-header { margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }
        .form-title { font-size: 20px; font-weight: 800; color: #1e272e; }
        .form-subtitle { font-size: 13px; color: #888; margin-top: 4px; }

        .form-group { margin-bottom: 22px; }
        .form-label { display: block; font-size: 14px; font-weight: 700; color: #2d3436; margin-bottom: 8px; }

        .input-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #e1e4e8;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
            font-family: inherit;
        }
        .input-control:focus { border-color: #4caf50; }
        .input-readonly { background-color: #f8f9fa; color: #666; cursor: not-allowed; }

        textarea.input-control { resize: vertical; min-height: 280px; line-height: 1.6; }

        .btn-group { display: flex; justify-content: flex-end; gap: 10px; margin-top: 30px; }
        .btn { padding: 11px 24px; border-radius: 8px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; transition: background 0.2s; }
        .btn-submit { background: #4caf50; color: #fff; box-shadow: 0 4px 10px rgba(76,175,80,0.25); }
        .btn-submit:hover { background: #388e3c; }
        .btn-cancel { background: #edf2f7; color: #4a5568; }
        .btn-cancel:hover { background: #e2e8f0; }
    </style>
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
