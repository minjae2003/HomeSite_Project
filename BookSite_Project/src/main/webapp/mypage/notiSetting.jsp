<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO" %>
<%
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