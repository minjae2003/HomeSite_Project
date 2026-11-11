<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.SiteInfo, member.ConsentDAO" %>
<%
    String consentUserId = (String) session.getAttribute("id");
    if (consentUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
    if (Boolean.TRUE.equals(ConsentDAO.getInstance().hasAgreed(consentUserId, SiteInfo.POLICY_VERSION))) {
        session.setAttribute(ConsentDAO.SESSION_KEY, SiteInfo.POLICY_VERSION);
        response.sendRedirect(request.getContextPath() + "/main/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>약관 동의 안내 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/policy.css">
    <link rel="stylesheet" href="../css/consent.css">
    <script src="../js/consent.js"></script>
    <style>
        .consent-page { max-width: 560px; }
        .consent-page h1 { font-size: 22px; }
        .consent-page .policy-intro { margin-bottom: 18px; }
        .consent-page ul { margin: 0 0 6px; }
        .consent-actions { display: flex; gap: 10px; margin-top: 20px; }
        .consent-actions button, .consent-actions a { flex: 1; padding: 14px; border-radius: 10px; font-size: 15px; font-weight: 700; text-align: center; text-decoration: none; border: none; cursor: pointer; font-family: inherit; }
        .consent-actions .btn-agree { flex: 2; background: #f95e07; color: #fff; }
        .consent-actions .btn-agree:hover { background: #e05000; }
        .consent-actions .btn-later { background: #e5e7eb; color: #374151; }
        .consent-note { margin-top: 14px; font-size: 12.5px; color: #94a3b8; line-height: 1.6; }
        .consent-note a { color: #64748b; }
    </style>
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="policy-wrap consent-page">
    <div class="policy-card">
        <h1>📋 약관 및 개인정보처리방침 시행 안내</h1>
        <div class="policy-meta">시행일: <%= SiteInfo.EFFECTIVE_DATE %></div>

        <div class="policy-intro">
            자취의 품격을 이용해 주셔서 감사합니다.<br>
            더 안전하고 투명한 운영을 위해 아래 문서를 새로 마련했습니다. 내용을 확인하시고 동의해 주시면 계속 이용하실 수 있어요.
        </div>
        <ul>
            <li><a href="terms.jsp" target="_blank" rel="noopener">이용약관</a>: 회원의 권리와 의무, 게시물 관리, 탈퇴 등</li>
            <li><a href="privacy.jsp" target="_blank" rel="noopener"><b>개인정보처리방침</b></a>: 수집 항목, 이용 목적, 보관 기간, 문의처</li>
            <li><a href="rules.jsp" target="_blank" rel="noopener">운영정책</a>: 커뮤니티 이용 규칙, 권리침해 신고 방법</li>
        </ul>
        <p style="font-size:13.5px;color:#64748b;">새로 수집하는 개인정보는 없으며, 기존에 입력하신 정보를 그대로 이용합니다.</p>

        <form name="consent_form" method="post" action="consentPro.jsp" onsubmit="return consentCheck(this);">
            <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
            <%@ include file="_consent_fields.jspf" %>
            <div class="consent-actions">
                <a class="btn-later" href="<%= request.getContextPath() %>/member/LogoutPro.jsp">로그아웃</a>
                <button type="submit" class="btn-agree">동의하고 계속하기</button>
            </div>
        </form>

        <p class="consent-note">
            동의하지 않으시면 로그인이 필요한 기능을 이용할 수 없으며, 로그아웃한 상태로 글을 읽는 것은 계속 가능합니다.
            탈퇴를 원하시면 <a href="<%= request.getContextPath() %>/mypage/account.jsp">계정 관리</a>에서 할 수 있어요.
            문의: <%= SiteInfo.CONTACT_EMAIL %>
        </p>
    </div>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
