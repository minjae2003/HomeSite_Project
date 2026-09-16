<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>자취의 품격</title>
    <!-- external css 불러오기 -->
    <link rel="stylesheet" href="../css/index.css">
</head>
<body>
	<%
    String sessionId = (String) session.getAttribute("id");
    String sessionName = (String) session.getAttribute("name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = sessionId;
%>
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
                <!-- 공지사항 카드 (DB 연동) -->
<div class="board-card" onclick="location.href='../noticeboard/list.jsp'">
    <div class="card-header">
        <div class="card-icon">📢</div>
        <div class="card-title">공지사항</div>
    </div>
    <ul class="post-list">
        <%
            board.BoardDAO noticeDao = board.BoardDAO.getInstance();
            java.util.List<board.BoardVO> noticeList = noticeDao.getNotices(0, 3, "ALL");
            if (noticeList == null || noticeList.isEmpty()) {
        %>
            <li style="color: #999; text-align: center; padding: 10px 0;">등록된 공지사항이 없습니다.</li>
        <%
            } else {
                for (board.BoardVO item : noticeList) {
                    boolean isFixed = "FIX".equals(item.getNoticeType());
        %>
            <li>
                <a href="../noticeboard/content.jsp?num=<%= item.getNum() %>" onclick="event.stopPropagation();">
                    <%= isFixed ? "📌 " : "" %><%= item.getSubject() %>
                </a>
            </li>
        <%
                }
            }
        %>
    </ul>
</div>

                <!-- 자취꿀팁 카드 (DB 연동) -->
                <div class="board-card" onclick="location.href='../freeboard/list.jsp'">
                    <div class="card-header">
                        <div class="card-icon">💡</div>
                        <div class="card-title">자취꿀팁</div>
                    </div>
                    <ul class="post-list">
                        <%
                            board.BoardDAO tipDao = board.BoardDAO.getInstance();
                            java.util.List<board.BoardVO> tipList = tipDao.getArticles(0, 3, "TIP");
                            if (tipList == null || tipList.isEmpty()) {
                        %>
                            <li style="color: #999; text-align: center; padding: 10px 0;">등록된 꿀팁이 없습니다.</li>
                        <%
                            } else {
                                for (board.BoardVO item : tipList) {
                        %>
                            <li>
                                <a href="../freeboard/content.jsp?num=<%= item.getNum() %>" onclick="event.stopPropagation();">
                                    <%= item.getSubject() %>
                                </a>
                            </li>
                        <%
                                }
                            }
                        %>
                    </ul>
                </div>

                <!-- 자유게시판 카드 (DB 연동) -->
                <div class="board-card" onclick="location.href='../freeboard/list.jsp'">
                    <div class="card-header">
                        <div class="card-icon">💬</div>
                        <div class="card-title">자유게시판</div>
                    </div>
                    <ul class="post-list">
                        <%
                            board.BoardDAO freeDao = board.BoardDAO.getInstance();
                            java.util.List<board.BoardVO> freeList = freeDao.getArticles(0, 3, "FREE");
                            if (freeList == null || freeList.isEmpty()) {
                        %>
                            <li style="color: #999; text-align: center; padding: 10px 0;">등록된 글이 없습니다.</li>
                        <%
                            } else {
                                for (board.BoardVO item : freeList) {
                        %>
                            <li>
                                <a href="../freeboard/content.jsp?num=<%= item.getNum() %>" onclick="event.stopPropagation();">
                                    <%= item.getSubject() %>
                                </a>
                            </li>
                        <%
                                }
                            }
                        %>
                    </ul>
                </div>

                <!-- 요리레시피 카드 -->
                <div class="board-card" onclick="location.href='../qna/qnaList.jsp'">
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

            <!-- 실시간 인기글 섹션 (category=BEST 연동) -->
            <div class="hot-posts-section">
                <div class="section-header">
                    <h2 class="section-title">실시간 인기글</h2>
                    <a href="../freeboard/list.jsp?category=BEST" class="btn-more">더보기 +</a>
                </div>
                <div class="hot-post-list">
                    <%
                        board.BoardDAO hotDao = board.BoardDAO.getInstance();
                        java.util.List<board.BoardVO> hotList = hotDao.getArticles(0, 5, "BEST");
                        if (hotList == null || hotList.isEmpty()) {
                    %>
                        <div style="padding: 30px; text-align: center; color: #94a3b8; font-size: 14px;">
                            등록된 인기글이 없습니다.
                        </div>
                    <%
                        } else {
                            String[] avatarColors = {"#818cf8", "#38bdf8", "#a78bfa", "#60a5fa", "#f43f5e"};
                            int colorIdx = 0;

                            for (board.BoardVO item : hotList) {
                                String color = avatarColors[colorIdx % avatarColors.length];
                                colorIdx++;

                                String icon = "🔥";
                                String cat = item.getCategory();
                                if ("TIP".equalsIgnoreCase(cat) || "꿀팁".equals(cat)) {
                                    icon = "💡";
                                } else if ("QNA".equalsIgnoreCase(cat) || "질문".equalsIgnoreCase(cat)) {
                                    icon = "❓";
                                } else if ("NOTICE".equalsIgnoreCase(cat) || "공지".equalsIgnoreCase(cat)) {
                                    icon = "📢";
                                } else if ("FREE".equalsIgnoreCase(cat) || "자유".equalsIgnoreCase(cat)) {
                                    icon = "💬";
                                }
                    %>
                        <div class="hot-post-item">
                            <div class="post-title-group">
                                <span class="post-icon"><%= icon %></span>
                                <a href="../freeboard/content.jsp?num=<%= item.getNum() %>" class="post-title">
                                    <%= item.getSubject() %>
                                </a>
                            </div>
                            <div class="post-author-group">
                                <span class="author-avatar" style="background-color: <%= color %>;"></span>
                                <span class="author-name"><%= item.getWriter() %></span>
                            </div>
                            <div class="post-stats">
                                <span>조회 <strong><%= item.getReadcount() %></strong></span>
                                <span class="divider">|</span>
                                <span>추천 <strong><%= item.getLikeCount() %></strong></span>
                            </div>
                        </div>
                    <%
                            }
                        }
                    %>
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
<%
    if (sessionId == null) {
%>
    <a href="../member/loginForm.jsp" class="btn btn-login">LOGIN<small>로그인</small></a>
    <a href="../member/memberForm.jsp" class="btn btn-signup">SIGN UP<small>회원가입</small></a>
<%
    } else {
%>
    <a href="../member/LogoutPro.jsp" class="btn btn-logout"><%= sessionName %>님<small>로그아웃</small></a>
<%
    }
%>
</div>

            <!-- 커뮤니티 현황 위젯 -->
<%
    int totalMemberCount = member.MemberDAO.getInstance().getMemberCount();
    int todayVisitorCount = visit.VisitDAO.getInstance().getTodayVisitorCount();
%>
<div class="status-card">
    <div class="widget-title">커뮤니티 현황</div>
    <div class="status-grid">
        <div class="status-item">
            <div class="status-value"><%= String.format("%,d", totalMemberCount) %></div>
            <div class="status-label">전체 회원</div>
        </div>
        <div class="status-item">
            <div class="status-value"><%= String.format("%,d", todayVisitorCount) %></div>
            <div class="status-label">오늘 방문자</div>
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
                <button type="button" class="btn-checklist" onclick="location.href='../noticeboard/content.jsp?num=11&pageNum=1&category=FIX'">체크리스트 보기</button>
            </div>
        </aside>
    </div>

</body>
</html>