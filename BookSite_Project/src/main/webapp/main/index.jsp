<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>자취의 품격</title>
<%
    String seoBase = seo.SiteUrl.base(request);
%>
    <meta name="description" content="<%= HtmlUtil.esc(seo.SiteUrl.SITE_DESC) %>">
    <link rel="canonical" href="<%= HtmlUtil.esc(seoBase) %>/main/index.jsp">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="자취의 품격">
    <meta property="og:title" content="자취의 품격 - 자취생 커뮤니티">
    <meta property="og:description" content="<%= HtmlUtil.esc(seo.SiteUrl.SITE_DESC) %>">
    <meta property="og:url" content="<%= HtmlUtil.esc(seoBase) %>/main/index.jsp">
    <meta property="og:image" content="<%= HtmlUtil.esc(seoBase) %>/icon-512.png">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "자취의 품격",
      "alternateName": ["자취의품격", "jachiclass", "jachiclass.com"],
      "url": "<%= HtmlUtil.esc(seoBase) %>/"
    }
    </script>
    <link rel="stylesheet" href="../css/main/index.css">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
</head>
<body>
	<%
    String sessionId = (String) session.getAttribute("id");
    String sessionName = (String) session.getAttribute("name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = sessionId;
%>
    <jsp:include page="../module/header.jsp" flush="false"/>

    <div class="container">
        <main class="main-content">
            <div class="notice-banner">
                📢 필독! 자취의 품격 공지사항 <br>
                <small>[공지] 9월 사이트 완성작업 및 서버 안정화 작업 안내 (09/07~)</small>
            </div>

            <div class="board-grid">
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
                    <%= isFixed ? "📌 " : "" %><%= HtmlUtil.esc(item.getSubject()) %>
                </a>
            </li>
        <%
                }
            }
        %>
    </ul>
</div>

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
                                    <%= HtmlUtil.esc(item.getSubject()) %>
                                </a>
                            </li>
                        <%
                                }
                            }
                        %>
                    </ul>
                </div>

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
                                    <%= HtmlUtil.esc(item.getSubject()) %>
                                </a>
                            </li>
                        <%
                                }
                            }
                        %>
                    </ul>
                </div>

                <div class="board-card" onclick="location.href='../freeboard/list.jsp?category=RECIPE'">
                    <div class="card-header">
                        <div class="card-icon">🍳</div>
                        <div class="card-title">요리레시피</div>
                    </div>
                    <ul class="post-list">
                        <%
                            board.BoardDAO recipeDao = board.BoardDAO.getInstance();
                            java.util.List<board.BoardVO> recipeList = recipeDao.getArticles(0, 3, "RECIPE");
                            if (recipeList == null || recipeList.isEmpty()) {
                        %>
                            <li style="color: #999; text-align: center; padding: 10px 0;">등록된 레시피가 없습니다.</li>
                        <%
                            } else {
                                for (board.BoardVO item : recipeList) {
                        %>
                            <li>
                                <a href="../freeboard/content.jsp?num=<%= item.getNum() %>&category=RECIPE" onclick="event.stopPropagation();">
                                    <%= HtmlUtil.esc(item.getSubject()) %>
                                </a>
                            </li>
                        <%
                                }
                            }
                        %>
                    </ul>
                </div>
            </div>

            <div class="hot-posts-section">
                <div class="section-header">
                    <h2 class="section-title">실시간 인기글 <small class="hot-window">최근 <%= board.BoardDAO.HOT_WINDOW_HOURS %>시간</small></h2>
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
                                    <%= HtmlUtil.esc(item.getSubject()) %>
                                </a>
                            </div>
                            <div class="post-author-group">
                                <span class="author-avatar" style="background-color: <%= color %>;"></span>
                                <span class="author-name"><%= HtmlUtil.esc(item.getWriterNickname() != null ? item.getWriterNickname() : item.getWriter()) %></span>
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
        
        <aside class="sidebar">
            	<form class="search-bar" action="search.jsp" method="get">
                    <input type="text" name="keyword" placeholder="SEARCH BAR">
                    <button type="submit">🔍</button>
                </form>
            

           <div class="auth-buttons">
<%
    if (sessionId == null) {
%>
    <a href="../member/loginForm.jsp" class="btn btn-login">LOGIN<small>로그인</small></a>
    <a href="../member/memberForm.jsp" class="btn btn-signup">SIGN UP<small>회원가입</small></a>
<%
    } else {
%>
    <a href="../member/LogoutPro.jsp" class="btn btn-logout"><%= HtmlUtil.esc(sessionName) %>님<small>로그아웃</small></a>
<%
    }
%>
</div>

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

            <div class="checklist-banner">
                <div class="banner-icon">🏠</div>
                <div class="banner-title">첫 자취 준비 중이신가요?</div>
                <div class="banner-desc">
                    신규 회원을 위한<br>
                    자취 시작 체크리스트를 확인해보세요.
                </div>
                <button type="button" class="btn-checklist" onclick="location.href='../main/checklist.jsp'">체크리스트 보기</button>
            </div>
        </aside>
    </div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>