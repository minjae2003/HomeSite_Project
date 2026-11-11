<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
<footer class="site-footer">
    <div class="site-footer-inner">
        <nav class="site-footer-links">
            <a href="${pageContext.request.contextPath}/policy/terms.jsp">이용약관</a>
            <a href="${pageContext.request.contextPath}/policy/privacy.jsp" class="privacy">개인정보처리방침</a>
            <a href="${pageContext.request.contextPath}/policy/rules.jsp">운영정책</a>
            <a href="${pageContext.request.contextPath}/policy/rules.jsp#report">권리침해 신고</a>
            <a href="${pageContext.request.contextPath}/support/inquiry.jsp">문의하기</a>
            <% if ("ADMIN".equals(session.getAttribute("role"))) {
                   int ftWait = inquiry.InquiryDAO.getInstance().countAll("WAIT"); %>
            <a href="${pageContext.request.contextPath}/admin/members.jsp" class="admin">🛠 관리자 메뉴<%= ftWait > 0 ? " (문의 " + ftWait + ")" : "" %></a>
            <% } %>
        </nav>
        <p class="site-footer-info">
            <%= util.SiteInfo.SITE_NAME %> · 운영 <%= util.SiteInfo.OPERATOR %> · 문의 <%= util.SiteInfo.CONTACT_EMAIL %>
        </p>
        <p class="site-footer-copy">© 2026 <%= util.SiteInfo.SITE_NAME %>. All rights reserved.</p>
    </div>
</footer>
