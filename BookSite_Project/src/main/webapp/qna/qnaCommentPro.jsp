<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

    int num = Integer.parseInt(request.getParameter("num"));
    String pageNum = request.getParameter("pageNum");
    String comment = request.getParameter("comment");

    String writer = (String) session.getAttribute("id");
    if (writer == null || writer.trim().equals("")) {
        writer = "손님";
    }

    QnaDAO dao = QnaDAO.getInstance();
    dao.insertQnaComment(num, writer, comment);

    response.sendRedirect("qnaDetail.jsp?num=" + num + "&pageNum=" + pageNum);
%>