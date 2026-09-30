<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO" %>
<%
    // 내 알림 모두 읽음 처리 후 원래 페이지로 돌아감
    request.setCharacterEncoding("UTF-8");
    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        NotificationDAO.getInstance().markAllRead(sessionUserId);
    }

    // 돌아갈 주소는 이 사이트 내부 경로만 허용 (외부 사이트로 튕겨내는 오픈 리다이렉트 방지)
    String returnUrl = request.getParameter("returnUrl");
    String ctx = request.getContextPath();
    if (returnUrl == null || !returnUrl.startsWith(ctx + "/") || returnUrl.startsWith("//")
            || returnUrl.contains("\r") || returnUrl.contains("\n")) {
        returnUrl = ctx + "/mypage/notifications.jsp";
    }
    response.sendRedirect(returnUrl);
%>
