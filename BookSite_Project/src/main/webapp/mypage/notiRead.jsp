<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO, notification.NotificationVO" %>
<%
    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    String numStr = request.getParameter("num");
    if (numStr == null || !numStr.matches("\\d{1,9}")) {
        response.sendRedirect("notifications.jsp");
        return;
    }
    int notiNum = Integer.parseInt(numStr);

    NotificationDAO dao = NotificationDAO.getInstance();
    NotificationVO noti = dao.get(notiNum, sessionUserId);
    if (noti == null) {
        response.sendRedirect("notifications.jsp");
        return;
    }

    dao.markRead(notiNum, sessionUserId);

    if (noti.isInquiry()) {
        response.sendRedirect(request.getContextPath() + noti.getLinkPath());
        return;
    }
    if (noti.getBoardType() == null) {
        out.println("<script>alert('삭제된 게시글입니다.'); location.href='notifications.jsp';</script>");
        return;
    }
    response.sendRedirect(request.getContextPath() + noti.getLinkPath());
%>
