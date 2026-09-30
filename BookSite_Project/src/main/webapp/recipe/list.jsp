<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 요리레시피 게시판은 자유게시판의 RECIPE 카테고리로 통합되었습니다.
    // 예전 주소(북마크 등)로 들어와도 자유게시판 레시피 탭으로 이동시킵니다.
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
