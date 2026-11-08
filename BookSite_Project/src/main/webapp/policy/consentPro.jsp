<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.SiteInfo, member.ConsentDAO" %>
<%
    // 상태를 바꾸는 요청은 POST만 허용 (CSRF 토큰 검사는 CsrfFilter)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("consent.jsp");
        return;
    }
    String consentUserId = (String) session.getAttribute("id");
    if (consentUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
    if (!"Y".equals(request.getParameter("agree_terms")) || !"Y".equals(request.getParameter("agree_privacy"))) {
        out.println("<script>alert('필수 항목에 모두 동의해 주세요.'); history.back();</script>");
        return;
    }
    if (!ConsentDAO.getInstance().agree(consentUserId, SiteInfo.POLICY_VERSION)) {
        out.println("<script>alert('처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); history.back();</script>");
        return;
    }
    session.setAttribute(ConsentDAO.SESSION_KEY, SiteInfo.POLICY_VERSION);
    out.println("<script>alert('동의해 주셔서 감사합니다. 자취의 품격을 계속 이용하실 수 있어요!'); location.href='"
            + request.getContextPath() + "/main/index.jsp';</script>");
%>
