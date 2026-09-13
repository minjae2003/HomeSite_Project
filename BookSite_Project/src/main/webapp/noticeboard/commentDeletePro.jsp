<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.CommentDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String commentNumParam = request.getParameter("commentNum");
    String boardNumParam = request.getParameter("boardNum");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    if (pageNum == null) pageNum = "1";
    if (category == null) category = "ALL";

    if (commentNumParam != null && boardNumParam != null) {
        int commentNum = Integer.parseInt(commentNumParam);
        CommentDAO dao = CommentDAO.getInstance();
        dao.deleteComment(commentNum);
    }

    response.sendRedirect("content.jsp?num=" + boardNumParam + "&pageNum=" + pageNum + "&category=" + category);
%>