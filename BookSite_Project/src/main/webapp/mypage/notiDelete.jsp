<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO" %>
<%
    // 알림 1건 삭제 (본인 알림만) 후 원래 페이지로 돌아감
    request.setCharacterEncoding("UTF-8");
    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    String numStr = request.getParameter("num");
    if ("POST".equalsIgnoreCase(request.getMethod()) && numStr != null && numStr.matches("\\d{1,9}")) {
        NotificationDAO.getInstance().delete(Integer.parseInt(numStr), sessionUserId);
    }

    // 돌아갈 주소는 이 사이트 내부 경로만 허용 (오픈 리다이렉트 방지)
    String returnUrl = request.getParameter("returnUrl");
    String ctx = request.getContextPath();
    if (returnUrl == null || !returnUrl.startsWith(ctx + "/") || returnUrl.startsWith("//")
            || returnUrl.contains("\r") || returnUrl.contains("\n")) {
        returnUrl = ctx + "/mypage/notifications.jsp";
    }
    response.sendRedirect(returnUrl);
%>