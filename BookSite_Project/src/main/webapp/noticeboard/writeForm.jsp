<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
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
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Pretendard', 'Malgun Gothic', sans-serif; background-color: #f7f9fa; color: #333; line-height: 1.5; }
        a { text-decoration: none; color: inherit; }

        /* 상단 네비게이션바 */
        .navbar { background: #fff; border-bottom: 1px solid #eaeaea; padding: 15px 0; }
        .nav-container { max-width: 1000px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; }
        .logo { font-size: 20px; font-weight: 800; color: #ff5722; display: flex; align-items: center; gap: 8px; }
        .logo-icon { background: #ff5722; color: #fff; padding: 4px 8px; border-radius: 8px; font-size: 14px; }

        /* 메인 컨테이너 */
        .container { max-width: 800px; margin: 40px auto; padding: 0 20px; }
        .card { background: #fff; border-radius: 12px; border: 1px solid #eaeaea; padding: 35px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); }
        
        .form-header { margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }
        .form-title { font-size: 20px; font-weight: 800; color: #1e272e; }
        .form-subtitle { font-size: 13px; color: #888; margin-top: 4px; }

        .form-group { margin-bottom: 22px; }
        .form-label { display: block; font-size: 14px; font-weight: 700; color: #2d3436; margin-bottom: 8px; }

        /* 카테고리 라디오 버튼 선택 스타일 */
        .category-select-group { display: flex; gap: 10px; flex-wrap: wrap; }
        .category-select-group input[type="radio"] { display: none; }
        
        .cat-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 18px;
            border-radius: 25px;
            border: 1px solid #e1e4e8;
            background: #fff;
            color: #555;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .category-select-group input[type="radio"]:checked + .cat-btn {
            background: #1e272e;
            color: #fff;
            border-color: #1e272e;
            box-shadow: 0 3px 8px rgba(0,0,0,0.15);
        }

        .cat-btn:hover { border-color: #1e272e; }

        /* 입력 폼 스타일 */
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
        .input-control:focus { border-color: #ff5722; }
        .input-readonly { background-color: #f8f9fa; color: #666; cursor: not-allowed; }

        textarea.input-control { resize: vertical; min-height: 250px; line-height: 1.6; }

        /* 버튼 그룹 */
        .btn-group { display: flex; justify-content: flex-end; gap: 10px; margin-top: 30px; }
        .btn { padding: 11px 24px; border-radius: 8px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; transition: background 0.2s; }
        .btn-submit { background: #ff5722; color: #fff; box-shadow: 0 4px 10px rgba(255,87,34,0.25); }
        .btn-submit:hover { background: #e64a19; }
        .btn-cancel { background: #edf2f7; color: #4a5568; }
        .btn-cancel:hover { background: #e2e8f0; }
    </style>
</head>
<body>

<!-- 상단 네비게이션 바 -->
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

        <form action="writePro.jsp" method="post">
            <!-- 1. 카테고리 선택 영역 -->
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

            <!-- 2. 작성자 표시 -->
            <div class="form-group">
                <label class="form-label">작성자</label>
                <input type="text" class="input-control input-readonly" value="<%= sessionUserNick %>" readonly>
            </div>

            <!-- 3. 제목 입력 -->
            <div class="form-group">
                <label class="form-label">제목</label>
                <input type="text" name="subject" class="input-control" placeholder="제목을 입력해 주세요." required autofocus>
            </div>

            <!-- 4. 내용 입력 -->
            <div class="form-group">
                <label class="form-label">내용</label>
                <textarea name="content" class="input-control" placeholder="자취생들과 나누고 싶은 이야기를 자유롭게 작성해 주세요." required></textarea>
            </div>

            <!-- 5. 하단 버튼 -->
            <div class="btn-group">
                <button type="button" class="btn btn-cancel" onclick="location.href='list.jsp'">취소</button>
                <button type="submit" class="btn btn-submit">게시글 등록</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>