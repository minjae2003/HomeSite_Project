<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil, member.MemberDAO, member.MemberVO, java.util.List, java.text.SimpleDateFormat" %>
<%
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        out.println("<script>alert('관리자만 볼 수 있는 페이지입니다.'); location.href='" + request.getContextPath() + "/main/index.jsp';</script>");
        return;
    }
    String adminTab = "members";
    String me = (String) session.getAttribute("id");

    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("q");
    keyword = keyword == null ? "" : keyword.trim();
    if (keyword.length() > 50) keyword = keyword.substring(0, 50);
    String filter = request.getParameter("filter");
    if (!"SUSPENDED".equals(filter) && !"ADMIN".equals(filter)) filter = "ALL";
    String pageNum = request.getParameter("pageNum");
    int currentPage = (pageNum != null && pageNum.matches("\\d{1,6}")) ? Math.max(1, Integer.parseInt(pageNum)) : 1;
    int pageSize = 20;

    MemberDAO dao = MemberDAO.getInstance();
    int total = dao.adminCount(keyword, filter);
    List<MemberVO> list = dao.adminList(keyword, filter, (currentPage - 1) * pageSize, pageSize);
    int pageCount = Math.max(1, (Math.max(total, 0) + pageSize - 1) / pageSize);
    int suspendedCount = dao.adminCount("", "SUSPENDED");

    String qs = "q=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&filter=" + filter;
    SimpleDateFormat day = new SimpleDateFormat("yyyy.MM.dd");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>회원 관리 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/support.css">
    <link rel="stylesheet" href="../css/admin.css">
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="sp-wrap wide">
    <div class="sp-head">
        <div>
            <h1>👥 회원 관리</h1>
            <p>전체 <b><%= Math.max(0, dao.adminCount("", "ALL")) %></b>명 · 이용 정지 <b style="color:#dc2626;"><%= Math.max(0, suspendedCount) %></b>명</p>
        </div>
    </div>
    <%@ include file="_nav.jspf" %>

    <form class="am-search" method="get" action="members.jsp">
        <select name="filter">
            <option value="ALL" <%= "ALL".equals(filter) ? "selected" : "" %>>전체 회원</option>
            <option value="SUSPENDED" <%= "SUSPENDED".equals(filter) ? "selected" : "" %>>정지된 회원</option>
            <option value="ADMIN" <%= "ADMIN".equals(filter) ? "selected" : "" %>>관리자</option>
        </select>
        <input type="text" name="q" value="<%= HtmlUtil.esc(keyword) %>" placeholder="아이디, 닉네임, 이름, 이메일 검색">
        <button type="submit" class="sp-btn primary small">검색</button>
        <% if (!keyword.isEmpty() || !"ALL".equals(filter)) { %><a class="sp-btn gray small" href="members.jsp">초기화</a><% } %>
    </form>

    <% if (list == null) { %>
        <div class="sp-card sp-note">회원 목록을 불러오지 못했어요. 서버 DB에 정지 기능 컬럼(suspend_until)이 추가되었는지 확인해 주세요.</div>
    <% } else if (list.isEmpty()) { %>
        <div class="sp-card sp-empty">해당하는 회원이 없어요.</div>
    <% } else { %>
    <div class="am-table-wrap">
    <table class="am-table">
        <thead>
            <tr><th>회원</th><th>이메일</th><th>가입일</th><th class="num">글</th><th class="num">댓글</th><th>상태</th><th>관리</th></tr>
        </thead>
        <tbody>
        <% for (MemberVO m : list) {
               boolean isAdminRow = "ADMIN".equals(m.getRole());
               boolean isMe = m.getId().equals(me);
        %>
            <tr class="<%= m.isSuspended() ? "suspended" : "" %>">
                <td data-label="회원">
                    <b><%= HtmlUtil.esc(m.getNickname()) %></b>
                    <% if (isAdminRow) { %><span class="am-badge admin">관리자</span><% } %>
                    <div class="am-sub"><%= HtmlUtil.esc(m.getId()) %> · <%= HtmlUtil.esc(m.getName()) %></div>
                </td>
                <td data-label="이메일" class="am-email"><%= m.getEmail() == null || m.getEmail().isEmpty() ? "-" : HtmlUtil.esc(m.getEmail()) %></td>
                <td data-label="가입일"><%= m.getRegDate() == null ? "-" : day.format(m.getRegDate()) %></td>
                <td data-label="글" class="num"><%= m.getPostCount() %></td>
                <td data-label="댓글" class="num"><%= m.getCommentCount() %></td>
                <td data-label="상태">
                    <% if (m.isSuspended()) { %>
                        <span class="am-badge stop">정지 (<%= m.getSuspendUntilText() %>)</span>
                        <% if (m.getSuspendReason() != null && !m.getSuspendReason().isEmpty()) { %><div class="am-sub">사유: <%= HtmlUtil.esc(m.getSuspendReason()) %></div><% } %>
                    <% } else { %>
                        <span class="am-badge ok">정상</span>
                    <% } %>
                </td>
                <td data-label="관리" class="am-actions">
                <% if (isAdminRow || isMe) { %>
                    <span class="am-sub">-</span>
                <% } else { %>
                    <% if (m.isSuspended()) { %>
                        <form method="post" action="memberPro.jsp" onsubmit="return confirm('<%= HtmlUtil.esc(HtmlUtil.js(m.getNickname())) %>님의 이용 정지를 해제할까요?');">
                            <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                            <input type="hidden" name="action" value="unsuspend">
                            <input type="hidden" name="id" value="<%= HtmlUtil.esc(m.getId()) %>">
                            <input type="hidden" name="back" value="<%= HtmlUtil.esc(qs + "&pageNum=" + currentPage) %>">
                            <button type="submit" class="sp-btn small gray">정지 해제</button>
                        </form>
                    <% } else { %>
                        <details class="am-suspend">
                            <summary class="sp-btn small danger">이용 정지</summary>
                            <form method="post" action="memberPro.jsp" onsubmit="return confirm('<%= HtmlUtil.esc(HtmlUtil.js(m.getNickname())) %>님을 이용 정지할까요?');">
                                <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                                <input type="hidden" name="action" value="suspend">
                                <input type="hidden" name="id" value="<%= HtmlUtil.esc(m.getId()) %>">
                                <input type="hidden" name="back" value="<%= HtmlUtil.esc(qs + "&pageNum=" + currentPage) %>">
                                <select name="days">
                                    <option value="1">1일</option>
                                    <option value="3">3일</option>
                                    <option value="7" selected>7일</option>
                                    <option value="30">30일</option>
                                    <option value="0">영구</option>
                                </select>
                                <input type="text" name="reason" maxlength="200" placeholder="사유 (회원에게 표시됨)" required>
                                <button type="submit" class="sp-btn small primary">정지</button>
                            </form>
                        </details>
                    <% } %>
                    <form method="post" action="memberPro.jsp"
                          onsubmit="return confirm('<%= HtmlUtil.esc(HtmlUtil.js(m.getNickname())) %>님을 강제 탈퇴시킬까요?\n\n회원 정보와 작성한 글·댓글·첨부파일이 모두 삭제되며 되돌릴 수 없어요.');">
                        <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= HtmlUtil.esc(m.getId()) %>">
                        <input type="hidden" name="back" value="<%= HtmlUtil.esc(qs) %>">
                        <button type="submit" class="sp-btn small danger-outline">강제 탈퇴</button>
                    </form>
                <% } %>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>
    </div>

    <% if (pageCount > 1) { %>
    <div class="sp-paging">
        <% for (int i = 1; i <= pageCount; i++) { %>
            <a href="members.jsp?<%= HtmlUtil.esc(qs) %>&amp;pageNum=<%= i %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
        <% } %>
    </div>
    <% } %>
    <% } %>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
