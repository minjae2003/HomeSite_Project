<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="inquiry.InquiryDAO" %>
<%
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("myInquiries.jsp");
        return;
    }
    String inqUserId = (String) session.getAttribute("id");
    if (inqUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
    String numStr = request.getParameter("num");
    if (numStr == null || !numStr.matches("\\d{1,9}")) {
        response.sendRedirect("myInquiries.jsp");
        return;
    }
    boolean ok = InquiryDAO.getInstance().deleteOwn(Integer.parseInt(numStr), inqUserId);
    out.println("<script>alert('" + (ok ? "문의를 삭제했어요." : "삭제할 수 없는 문의입니다. (이미 답변된 문의는 삭제할 수 없어요)")
            + "'); location.href='myInquiries.jsp';</script>");
%>
