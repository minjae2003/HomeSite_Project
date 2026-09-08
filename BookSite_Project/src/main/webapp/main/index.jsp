<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>자취의 품격</title>
    <!-- external css 불러오기 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
</head>
<body>

    <!-- Header 모듈 불러오기 -->
    <jsp:include page="../module/header.jsp" flush="false"/>

    <div class="container">
        <!-- 메인 콘텐츠 영역 -->
        <main class="main-content">
            <div class="notice-banner">
                📢 필독! 자취의 품격 공지사항 <br>
                <small>[공지] 9월 사이트 완성작업 및 서버 안정화 작업 안내 (09/07~)</small>
            </div>

            <div class="board-grid">
                <!-- 공지사항 카드 -->
                <div class="board-card" onclick="location.href='boardList.do?category=notice'">
                    <div class="card-header">
                        <div class="card-icon">📢</div>
                        <div class="card-title">공지사항</div>
                    </div>
                    <ul class="post-list">
                        <li><a href="boardDetail.do?id=101" onclick="event.stopPropagation();">[필독] 커뮤니티 이용 규칙</a></li>
                        <li><a href="boardDetail.do?id=102" onclick="event.stopPropagation();">[안내] 제1회 요리 대회 개최</a></li>
                        <li><a href="boardDetail.do?id=103" onclick="event.stopPropagation();">[공지] 서버 점검 안내</a></li>
                    </ul>
                </div>

                <!-- 자취꿀팁 카드 -->
                <div class="board-card" onclick="location.href='boardList.do?category=tip'">
                    <div class="card-header">
                        <div class="card-icon">💡</div>
                        <div class="card-title">자취꿀팁</div>
                    </div>
                    <ul class="post-list">
                        <li><a href="boardDetail.do?id=201" onclick="event.stopPropagation();">원룸 청소 필수템 BEST 5</a></li>
                        <li><a href="boardDetail.do?id=202" onclick="event.stopPropagation();">보증금 반환받는 절차 정리</a></li>
                        <li><a href="boardDetail.do?id=203" onclick="event.stopPropagation();">한달 식비 20만원으로 살기</a></li>
                    </ul>
                </div>

                <!-- 자유게시판 카드 -->
                <div class="board-card" onclick="location.href='boardList.do?category=free'">
                    <div class="card-header">
                        <div class="card-icon">💬</div>
                        <div class="card-title">자유게시판</div>
                    </div>
                    <ul class="post-list">
                        <li><a href="boardDetail.do?id=301" onclick="event.stopPropagation();">오늘 저녁 메뉴 추천 부탁해요!</a></li>
                        <li><a href="boardDetail.do?id=302" onclick="event.stopPropagation();">옆집 층간소음 때문에 미치겠어요</a></li>
                        <li><a href="boardDetail.do?id=303" onclick="event.stopPropagation();">자취 3년 차, 유익했던 자취템</a></li>
                    </ul>
                </div>

                <!-- 요리레시피 카드 -->
                <div class="board-card" onclick="location.href='boardList.do?category=recipe'">
                    <div class="card-header">
                        <div class="card-icon">🍳</div>
                        <div class="card-title">요리레시피</div>
                    </div>
                    <ul class="post-list">
                        <li><a href="boardDetail.do?id=401" onclick="event.stopPropagation();">5분 완성! 마늘 볶음밥</a></li>
                        <li><a href="boardDetail.do?id=402" onclick="event.stopPropagation();">냉장고 파먹기: 간단 김치찌개</a></li>
                        <li><a href="boardDetail.do?id=403" onclick="event.stopPropagation();">초간단 간장계란밥 황금 레시피</a></li>
                    </ul>
                </div>
            </div>
        </main>

        <!-- 사이드바 영역 -->
        <aside class="sidebar">
            <div class="sidebar-box">
                <div class="search-bar">
                    <input type="text" placeholder="SEARCH BAR">
                    <button>🔍</button>
                </div>
            </div>

            <div class="auth-buttons">
                <a href="../member/loginForm.jsp" class="btn btn-login">LOGIN</a>
                <a href="../member/memberForm.jsp" class="btn btn-signup">SIGN UP</a>
            </div>

            <div class="sidebar-box">
                <strong>POPULAR TAGS</strong>
                <div class="tags">
                    <span class="tag">원룸</span>
                    <span class="tag">요리</span>
                    <span class="tag">계약</span>
                    <span class="tag">청소</span>
                    <span class="tag">자취템</span>
                    <span class="tag">야식</span>
                </div>
            </div>
            <div class="sidebar-box"onclick="location.href='boardList.do?category=tip'">
                <strong>실시간 베스트</strong>
                <ol class="best-list" style="margin-top: 10px;">
                    <li><a href="boardDetail.do?id=403" onclick="event.stopPropagation();">5분 완성! 자취생 마늘 볶음밥</a></li>
                    <li><a href="boardDetail.do?id=403" onclick="event.stopPropagation();">냉장고 파먹기: 간단 김치찌개</a></li>
                    <li><a href="boardDetail.do?id=403" onclick="event.stopPropagation();">보증금 반환받는 절차 완벽 정리</a></li>
                    <li><a href="boardDetail.do?id=403" onclick="event.stopPropagation();">초간단 간장계란밥 황금 레시피/a></li>
                    <li><a href="boardDetail.do?id=403" onclick="event.stopPropagation();">원룸 청소 필수템 BEST 5</a></li>
                </ol>
            </div>
        </aside>
    </div>

</body>
</html>