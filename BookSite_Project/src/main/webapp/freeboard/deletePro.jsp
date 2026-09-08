<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="freeboard.FreeboardDAO" %>

<%
	request.setCharacterEncoding("UTF-8");

	int num = Integer.parseInt(request.getParameter("num"));

	String pageNumStr = request.getParameter("pageNum");
	if(pageNumStr == null) {
		pageNumStr = "1";
	}
	int pageNum = Integer.parseInt(pageNumStr);

	String id = (String) session.getAttribute("id");

	if(id == null || id.equals("")) {
		response.sendRedirect("../main/main.jsp");
		return;
	}

	FreeboardDAO fbdao = FreeboardDAO.getInstance();
	fbdao.deleteFreeboard(num);

	response.sendRedirect("list.jsp?pageNum=" + pageNum);
%>