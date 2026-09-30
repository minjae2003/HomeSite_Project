<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 요리레시피 게시판은 자유게시판의 RECIPE 카테고리로 통합되었습니다.
    // 예전 상세보기 주소로 들어오면 자유게시판 상세보기로 이동시킵니다.
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
