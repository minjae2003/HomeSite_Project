<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO" %>
<%
    // 알림 수신 설정 변경 (댓글/추천/공지 중 하나를 켜거나 끔) 후 원래 페이지로 돌아감
    request.setCharacterEncoding("UTF-8");
    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    String type = request.getParameter("type");
    String on = request.getParameter("on");
    if ("POST".equalsIgnoreCase(request.getMethod()) && NotificationDAO.isValidType(type)
            && ("Y".equals(on) || "N".equals(on))) {
        NotificationDAO.getInstance().setSetting(sessionUserId, type, "Y".equals(on));
    }

    String returnUrl = request.getParameter("returnUrl");
    String ctx = request.getContextPath();
    if (returnUrl == null || !returnUrl.startsWith(ctx + "/") || returnUrl.startsWith("//")
            || returnUrl.contains("\r") || returnUrl.contains("\n")) {
        returnUrl = ctx + "/mypage/notifications.jsp";
    }
    response.sendRedirect(returnUrl + "#notiSetting");
%>