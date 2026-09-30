<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="notification.NotificationDAO, notification.NotificationVO" %>
<%
    // 알림 클릭: 읽음 처리 후 해당 게시글로 이동
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
    NotificationVO noti = dao.get(notiNum, sessionUserId);   // 본인 알림만 조회됨
    if (noti == null) {
        response.sendRedirect("notifications.jsp");
        return;
    }

    dao.markRead(notiNum, sessionUserId);

    if (noti.getBoardType() == null) {
        // 게시글이 삭제된 경우 (보통은 FK로 알림도 같이 지워짐)
        out.println("<script>alert('삭제된 게시글입니다.'); location.href='notifications.jsp';</script>");
        return;
    }
    response.sendRedirect(request.getContextPath() + noti.getLinkPath());
%>
