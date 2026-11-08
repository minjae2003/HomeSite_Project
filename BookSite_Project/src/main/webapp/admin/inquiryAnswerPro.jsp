<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="inquiry.InquiryDAO, inquiry.InquiryVO, notification.NotificationDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("inquiries.jsp");
        return;
    }
    String adminId = (String) session.getAttribute("id");
    if (adminId == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    String numStr = request.getParameter("num");
    String answer = request.getParameter("answer");
    answer = answer == null ? "" : answer.trim();
    String status = request.getParameter("status");
    if (!"WAIT".equals(status) && !"DONE".equals(status)) status = "ALL";
    String pageNum = request.getParameter("pageNum");
    if (pageNum == null || !pageNum.matches("\\d{1,6}")) pageNum = "1";
    String back = "inquiries.jsp?status=" + status + "&pageNum=" + pageNum;

    if (numStr == null || !numStr.matches("\\d{1,9}")) {
        response.sendRedirect(back);
        return;
    }
    if (answer.length() < 2 || answer.length() > 2000) {
        out.println("<script>alert('답변은 2~2000자로 입력해 주세요.'); history.back();</script>");
        return;
    }

    InquiryDAO dao = InquiryDAO.getInstance();
    InquiryVO q = dao.get(Integer.parseInt(numStr));
    if (q == null) {
        out.println("<script>alert('삭제되었거나 없는 문의입니다.'); location.href='" + back + "';</script>");
        return;
    }
    if (!dao.answer(q.getInquiryNum(), adminId, answer)) {
        out.println("<script>alert('답변 저장 중 오류가 발생했습니다.'); history.back();</script>");
        return;
    }
    String nick = (String) session.getAttribute("nickname");
    NotificationDAO.getInstance().notifyInquiryReply(q.getUserId(), adminId, nick != null ? nick : "운영자", q.getSubject(), answer);

    out.println("<script>alert('답변을 저장했어요. 회원에게 알림이 전송됩니다.'); location.href='" + back + "';</script>");
%>
