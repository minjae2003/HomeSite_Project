<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 로그인 정보 확인
    // (finalPage/index.jsp는 이 파일을 정적 include 하므로 변수 이름이 겹치지 않도록 hdr 접두사 사용)
    String id = (String) session.getAttribute("id");
    String hdrNick = (String) session.getAttribute("nickname");
    if (hdrNick == null || hdrNick.isEmpty()) hdrNick = (String) session.getAttribute("name");
    if (hdrNick == null || hdrNick.isEmpty()) hdrNick = id;
    if (hdrNick != null) {
        hdrNick = hdrNick.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    // 오늘 방문 기록 (세션당 하루 1번)
    visit.VisitDAO.getInstance().recordVisit(session.getId());

    // 알림 (로그인 상태일 때만 조회)
    int hdrUnread = 0;
    java.util.List<notification.NotificationVO> hdrNotis = null;
    String hdrReturnUrl = "";
    if (id != null) {
        notification.NotificationDAO hdrNotiDao = notification.NotificationDAO.getInstance();
        hdrUnread = hdrNotiDao.getUnreadCount(id);
        hdrNotis = hdrNotiDao.getList(id, 0, 5);

        // "모두 읽음 처리" 후 돌아올 현재 페이지 주소
        hdrReturnUrl = request.getRequestURI();
        if (request.getQueryString() != null) hdrReturnUrl += "?" + request.getQueryString();
        hdrReturnUrl = hdrReturnUrl.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
    }
%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">


<header>
    <div class="logo"><a href="${pageContext.request.contextPath}/main/index.jsp">🏠 자취의 품격</a></div>
    <nav>
        <ul>
            <li><a href="${pageContext.request.contextPath}/main/index.jsp">HOME</a></li>
            <li><a href="${pageContext.request.contextPath}/noticeboard/list.jsp">NOTICE<small>공지사항</small></a></li>
            <li><a href="${pageContext.request.contextPath}/freeboard/list.jsp">TIPS/BOARD<small>생활 꿀팁/자유게시판</small></a></li>
            <li><a href="${pageContext.request.contextPath}/mypage/index.jsp">MY PAGE<small>마이페이지</small></a></li>
        </ul>
    </nav>

    <!-- 검색 / 알림 / 로그인 상태 영역 -->
    <div class="header-auth">
        <!-- 통합검색 (main/search.jsp) -->
        <form class="header-search" action="${pageContext.request.contextPath}/main/search.jsp" method="get" role="search">
            <span class="header-search-icon">🔍</span>
            <input type="text" name="keyword" placeholder="검색어를 입력하세요" aria-label="검색어">
        </form>

        <!-- 알림 (비로그인 상태에서도 종은 보이고, 누르면 로그인 안내) -->
        <div class="notif-wrap">
            <button type="button" class="notif-bell" onclick="hdrToggleNotif(event)" aria-label="알림">
                🔔
                <% if (hdrUnread > 0) { %>
                <span class="notif-badge"><%= hdrUnread > 99 ? "99+" : String.valueOf(hdrUnread) %></span>
                <% } %>
            </button>
            <div class="notif-panel" id="notifPanel">
                <div class="notif-panel-head">
                    <h4>알림</h4>
                    <% if (hdrUnread > 0) { %>
                    <form method="post" action="${pageContext.request.contextPath}/mypage/notiReadAll.jsp" style="margin:0;">
                        <input type="hidden" name="returnUrl" value="<%= hdrReturnUrl %>">
                        <button type="submit" class="notif-mark-read">모두 읽음 처리</button>
                    </form>
                    <% } %>
                </div>
                <div class="notif-list">
                <% if (id == null) { %>
                    <div class="notif-empty">
                        로그인하면 내 글의 댓글·추천 소식과<br>새 공지사항 알림을 받을 수 있어요.
                        <a class="notif-login" href="${pageContext.request.contextPath}/member/loginForm.jsp">로그인하기</a>
                    </div>
                <% } else if (hdrNotis == null || hdrNotis.isEmpty()) { %>
                    <div class="notif-empty">새로운 알림이 없어요</div>
                <% } else {
                       for (notification.NotificationVO hdrN : hdrNotis) { %>
                    <a class="notif-item <%= hdrN.isRead() ? "" : "unread" %>"
                       href="${pageContext.request.contextPath}/mypage/notiRead.jsp?num=<%= hdrN.getNotiNum() %>">
                        <div class="notif-icon"><%= hdrN.getIcon() %></div>
                        <div class="notif-text">
                            <div class="notif-title"><%= hdrN.getMessageHtml() %></div>
                            <div class="notif-time"><%= hdrN.getTimeAgo() %></div>
                        </div>
                        <% if (!hdrN.isRead()) { %><div class="notif-dot"></div><% } %>
                    </a>
                <%     }
                   } %>
                </div>
                <% if (id != null) { %>
                <a class="notif-footer" href="${pageContext.request.contextPath}/mypage/notifications.jsp">전체 알림 보기</a>
                <% } %>
            </div>
        </div>

    <% if (id == null) { %>
        <a href="${pageContext.request.contextPath}/member/loginForm.jsp" class="btn-auth btn-login">로그인</a>
        <a href="${pageContext.request.contextPath}/member/memberForm.jsp" class="btn-auth btn-signup">회원가입</a>
    <% } else { %>
        <a href="${pageContext.request.contextPath}/member/LogoutPro.jsp" class="btn-auth btn-logout">로그아웃</a>
        <a href="${pageContext.request.contextPath}/mypage/index.jsp" class="user-nickname"><strong><%= hdrNick %></strong> 님</a>
    <% } %>
    </div>
</header>

<script>
    // 알림 패널 열기/닫기 (바깥을 누르면 닫힘)
    function hdrToggleNotif(e) {
        e.stopPropagation();
        var panel = document.getElementById('notifPanel');
        if (panel) panel.classList.toggle('open');
    }
    document.addEventListener('click', function (e) {
        var panel = document.getElementById('notifPanel');
        if (panel && panel.classList.contains('open') && !e.target.closest('.notif-wrap')) {
            panel.classList.remove('open');
        }
    });
</script>
