<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String target = request.getContextPath() + "/freeboard/list.jsp?category=RECIPE";

    String pageNum = request.getParameter("pageNum");
    if (pageNum != null && pageNum.matches("\\d+")) target += "&pageNum=" + pageNum;

    String keyword = request.getParameter("keyword");
    if (keyword != null && !keyword.trim().isEmpty()) {
        target += "&keyword=" + java.net.URLEncoder.encode(keyword.trim(), "UTF-8");
    }
    response.sendRedirect(target);
%>
