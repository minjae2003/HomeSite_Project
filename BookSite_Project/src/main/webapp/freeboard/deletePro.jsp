<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>

<%
    int num = Integer.parseInt(request.getParameter("num"));

    BoardDAO dao = BoardDAO.getInstance();
    dao.deleteBoard(num);

    response.sendRedirect("list.jsp");
%>