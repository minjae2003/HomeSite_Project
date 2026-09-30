<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO, notification.NotificationVO, board.BoardDAO, board.BoardVO, java.util.List" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    NotificationDAO dao = NotificationDAO.getInstance();

    // ── 필터 탭 (ALL / COMMENT / LIKE / NOTICE) ──
    String type = request.getParameter("type");
    if (!NotificationDAO.isValidType(type)) type = "ALL";
    String daoType = "ALL".equals(type) ? null : type;

    String[][] tabs = {
        {"ALL", "전체"}, {"COMMENT", "댓글"}, {"LIKE", "추천"}, {"NOTICE", "공지"}
    };

    // ── 페이징 ──
    int pageSize = 15;
    int currentPage = 1;
    String pageNumStr = request.getParameter("pageNum");
    if (pageNumStr != null && pageNumStr.matches("\\d{1,6}")) currentPage = Math.max(1, Integer.parseInt(pageNumStr));

    int total = dao.getCount(sessionUserId, daoType);
    int unreadAll = dao.getUnreadCount(sessionUserId);
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (currentPage > pageCount) currentPage = pageCount;
    List<NotificationVO> list = dao.getList(sessionUserId, daoType, (currentPage - 1) * pageSize, pageSize);

    // ── 사이드바: 수신 설정 / 최근 공지 ──
    boolean[] settings = dao.getSettings(sessionUserId);
    String[][] settingRows = { {"COMMENT", "댓글 알림"}, {"LIKE", "추천 알림"}, {"NOTICE", "공지사항 알림"} };
    List<BoardVO> recentNotices = BoardDAO.getInstance().getNotices(0, 3, "ALL");

    // 처리 후 돌아올 현재 페이지 주소
    String selfUrl = request.getContextPath() + "/mypage/notifications.jsp?type=" + type + "&pageNum=" + currentPage;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>전체 알림 — 자취의 품격</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/index.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/notifications.css">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="wrap">
  <div class="page-head">
    <div>
      <div class="breadcrumb"><a href="index.jsp">마이페이지</a> &gt; <b>전체 알림</b></div>
      <h1 class="page-title">전체 알림</h1>
    </div>
    <div class="page-head-actions">
      <a href="#notiSetting" class="btn btn-outline">알림 설정</a>
      <form method="post" action="notiReadAll.jsp" style="margin:0;">
        <input type="hidden" name="returnUrl" value="<%= esc(selfUrl) %>">
        <button type="submit" class="btn btn-ghost-purple" <%= unreadAll == 0 ? "disabled" : "" %>>모두 읽음 처리</button>
      </form>
    </div>
  </div>

  <div class="main-grid noti-grid">
    <main>
      <!-- 필터 탭 (숫자는 읽지 않은 알림 수) -->
      <div class="filter-tabs">
      <% for (String[] t : tabs) {
           int unread = dao.getUnreadCount(sessionUserId, "ALL".equals(t[0]) ? null : t[0]);
      %>
        <a href="notifications.jsp?type=<%= t[0] %>" class="filter-tab <%= t[0].equals(type) ? "active" : "" %>">
          <%= t[1] %><% if (unread > 0) { %> <span class="filter-count"><%= unread %></span><% } %>
        </a>
      <% } %>
      </div>

      <% if (list.isEmpty()) { %>
      <div class="notif-group">
        <div class="list-empty">
          <%= "ALL".equals(type) ? "아직 받은 알림이 없어요." : "이 종류의 알림이 없어요." %>
        </div>
      </div>
      <% } else {
           String currentGroup = null;
           for (NotificationVO n : list) {
               String group = n.getGroupLabel();
               if (!group.equals(currentGroup)) {
                   if (currentGroup != null) { %>
      </div>
      <%           } %>
      <div class="notif-group">
        <div class="group-label"><%= group %></div>
      <%           currentGroup = group;
               }
               String desc = n.getDescHtml();
      %>
        <div class="notif-row <%= n.isRead() ? "" : "unread" %>">
          <a class="notif-row-link" href="notiRead.jsp?num=<%= n.getNotiNum() %>">
            <div class="notif-row-icon"><%= n.getIcon() %></div>
            <div class="notif-row-text">
              <div class="notif-row-title"><%= n.getTitleHtml() %></div>
              <% if (desc != null) { %><div class="notif-row-desc"><%= desc %></div><% } %>
              <div class="notif-row-time"><%= n.getTimeText() %></div>
            </div>
          </a>
          <div class="notif-row-side">
            <% if (!n.isRead()) { %><span class="notif-row-dot" title="읽지 않음"></span><% } %>
            <form method="post" action="notiDelete.jsp" style="margin:0;" onsubmit="return confirm('이 알림을 삭제할까요?');">
              <input type="hidden" name="num" value="<%= n.getNotiNum() %>">
              <input type="hidden" name="returnUrl" value="<%= esc(selfUrl) %>">
              <button type="submit" class="notif-row-close" aria-label="알림 삭제">✕</button>
            </form>
          </div>
        </div>
      <%   } %>
      </div>
      <% } %>

      <% if (pageCount > 1) {
           int pageBlock = 5;
           int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
           int endPage = Math.min(startPage + pageBlock - 1, pageCount);
      %>
      <div class="pagination">
        <% if (startPage > 1) { %>
        <a class="page-num" href="notifications.jsp?type=<%= type %>&pageNum=<%= startPage - 1 %>">‹</a>
        <% } %>
        <% for (int i = startPage; i <= endPage; i++) { %>
        <a class="page-num <%= i == currentPage ? "active" : "" %>" href="notifications.jsp?type=<%= type %>&pageNum=<%= i %>"><%= i %></a>
        <% } %>
        <% if (endPage < pageCount) { %>
        <a class="page-num" href="notifications.jsp?type=<%= type %>&pageNum=<%= endPage + 1 %>">›</a>
        <% } %>
      </div>
      <% } %>
    </main>

    <aside>
      <!-- 알림 수신 설정 (스위치를 누르면 바로 저장) -->
      <div class="side-block" id="notiSetting">
        <p class="side-title">알림 수신 설정</p>
        <% for (int i = 0; i < settingRows.length; i++) { %>
        <form method="post" action="notiSetting.jsp" class="toggle-row">
          <span class="toggle-label"><%= settingRows[i][1] %></span>
          <input type="hidden" name="type" value="<%= settingRows[i][0] %>">
          <input type="hidden" name="on" value="<%= settings[i] ? "N" : "Y" %>">
          <input type="hidden" name="returnUrl" value="<%= esc(selfUrl) %>">
          <button type="submit" class="switch <%= settings[i] ? "on" : "" %>"
                  aria-label="<%= settingRows[i][1] %> <%= settings[i] ? "끄기" : "켜기" %>"></button>
        </form>
        <% } %>
        <p class="side-note">끈 알림은 새로 생기지 않아요. 이미 받은 알림은 그대로 남아요.</p>
      </div>

      <!-- 최근 공지사항 -->
      <div class="side-block">
        <p class="side-title">최근 공지사항</p>
        <% if (recentNotices == null || recentNotices.isEmpty()) { %>
          <p class="side-note" style="margin:0;">등록된 공지사항이 없어요.</p>
        <% } else {
             for (BoardVO nb : recentNotices) { %>
        <a class="notice-mini" href="../noticeboard/content.jsp?num=<%= nb.getNum() %>">
          <span class="dot"></span>
          <span class="txt"><%= esc(nb.getSubject()) %></span>
        </a>
        <%   }
           } %>
        <a class="side-link" href="../noticeboard/list.jsp">공지사항 전체 보기 ›</a>
      </div>
    </aside>
  </div>
</div>

</body>
</html>