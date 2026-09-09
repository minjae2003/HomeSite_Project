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
            <!-- 실시간 인기글 섹션 -->
            <div class="hot-posts-section" >
            	<div class="section-header">
        <h2 class="section-title">실시간 인기글</h2>
        <a href="${pageContext.request.contextPath}/boardList.do?category=popular" class="btn-more">더보기 +</a>
    			</div>
    			<div class="hot-post-list">
                    
                    <div class="hot-post-item">
                        <div class="post-title-group">
                            <span class="post-icon">📰</span>
                            <a href="${pageContext.request.contextPath}/boardDetail.do?id=501" class="post-title">어제 냉장고 파먹기 대성공!</a>
                        </div>
                        <div class="post-author-group">
                            <span class="author-avatar" style="background-color: #818cf8;"></span>
                            <span class="author-name">청소왕</span>
                        </div>
                        <div class="post-stats">
                            <span>조회 <strong>112</strong></span>
                            <span class="divider">|</span>
                            <span>추천 <strong>14</strong></span>
                        </div>
                    </div>

                    <div class="hot-post-item">
                        <div class="post-title-group">
                            <span class="post-icon">🌙</span>
                            <a href="${pageContext.request.contextPath}/boardDetail.do?id=502" class="post-title">원룸 층간소음 해결하신 분 계신가요?</a>
                        </div>
                        <div class="post-author-group">
                            <span class="author-avatar" style="background-color: #38bdf8;"></span>
                            <span class="author-name">21:55</span>
                        </div>
                        <div class="post-stats">
                            <span>조회 <strong>187</strong></span>
                            <span class="divider">|</span>
                            <span>추천 <strong>9</strong></span>
                        </div>
                    </div>

                    <div class="hot-post-item">
                        <div class="post-title-group">
                            <span class="post-icon">✅</span>
                            <a href="${pageContext.request.contextPath}/boardDetail.do?id=503" class="post-title">보증금 전입신고 꼭 하세요!!</a>
                        </div>
                        <div class="post-author-group">
                            <span class="author-avatar" style="background-color: #a78bfa;"></span>
                            <span class="author-name">정보통</span>
                        </div>
                        <div class="post-stats">
                            <span>조회 <strong>341</strong></span>
                            <span class="divider">|</span>
                            <span>추천 <strong>28</strong></span>
                        </div>
                    </div>

                    <div class="hot-post-item">
                        <div class="post-title-group">
                            <span class="post-icon">🍲</span>
                            <a href="${pageContext.request.contextPath}/boardDetail.do?id=504" class="post-title">냉장고 파먹기 대장정 시작!</a>
                        </div>
                        <div class="post-author-group">
                            <span class="author-avatar" style="background-color: #60a5fa;"></span>
                            <span class="author-name">살림왕2</span>
                        </div>
                        <div class="post-stats">
                            <span>조회 <strong>98</strong></span>
                            <span class="divider">|</span>
                            <span>추천 <strong>15</strong></span>
                        </div>
                    </div>

                    <div class="hot-post-item">
                        <div class="post-title-group">
                            <span class="post-icon">📷</span>
                            <a href="${pageContext.request.contextPath}/boardDetail.do?id=505" class="post-title">원룸 인테리어 소품 추천해주세요!</a>
                        </div>
                        <div class="post-author-group">
                            <span class="author-avatar" style="background-color: #818cf8;"></span>
                            <span class="author-name">감성인</span>
                        </div>
                        <div class="post-stats">
                            <span>조회 <strong>110</strong></span>
                            <span class="divider">|</span>
                            <span>추천 <strong>20</strong></span>
                        </div>
                    </div>

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
            <!-- 커뮤니티 현황 위젯 -->
    <div class="status-card">
        <div class="widget-title">커뮤니티 현황</div>
        <div class="status-grid">
            <div class="status-item">
                <div class="status-value">4,281</div>
                <div class="status-label">전체 회원</div>
            </div>
            <div class="status-item">
                <div class="status-value">312</div>
                <div class="status-label">오늘 방문자</div>
            </div>
            <div class="status-item">
                <div class="status-value">47</div>
                <div class="status-label">오늘 등록글</div>
            </div>
        </div>
    </div>

    <!-- 첫 자취 체크리스트 배너 -->
    <div class="checklist-banner">
        <div class="banner-icon">🏠</div>
        <div class="banner-title">첫 자취 준비 중이신가요?</div>
        <div class="banner-desc">
            신규 회원을 위한<br>
            자취 시작 체크리스트를 확인해보세요.
        </div>
        <button type="button" class="btn-checklist" onclick="location.href='${pageContext.request.contextPath}/checklist.do'">체크리스트 보기</button>
    </div>
        </aside>
    </div>

</body>
</html>