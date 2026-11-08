<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String num = request.getParameter("num");
    if (num == null || !num.matches("\\d+")) {
        response.sendRedirect(request.getContextPath() + "/freeboard/list.jsp?category=RECIPE");
        return;
    }
    String target = request.getContextPath() + "/freeboard/content.jsp?num=" + num + "&category=RECIPE";
    String pageNum = request.getParameter("pageNum");
    if (pageNum != null && pageNum.matches("\\d+")) target += "&pageNum=" + pageNum;
    response.sendRedirect(target);
%>
