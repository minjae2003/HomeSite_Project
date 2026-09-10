<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 세션에서 사용자 ID 가져오기 (프로젝트 환경에 따라 key값이 다를 수 있어 여러 개 체크)
    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) sessionUserId = (String) session.getAttribute("userId");
    if (sessionUserId == null) sessionUserId = (String) session.getAttribute("memberId");

    String numParam = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    if (pageNum == null) pageNum = "1";
    if (category == null) category = "ALL";

    // 1. 로그인 여부 확인
    if (sessionUserId == null || sessionUserId.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('로그인이 필요한 서비스입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    if (numParam != null && !numParam.trim().isEmpty()) {
        int num = Integer.parseInt(numParam);
        BoardDAO dao = BoardDAO.getInstance();
        
        // 2. 추천 / 취소 토글 수행
        boolean isLiked = dao.toggleLike(num, sessionUserId);

        out.println("<script>");
        if (isLiked) {
            out.println("alert('게시글을 추천하였습니다.');");
        } else {
            out.println("alert('추천을 취소하였습니다.');");
        }
        out.println("location.href='content.jsp?num=" + num + "&pageNum=" + pageNum + "&category=" + category + "';");
        out.println("</script>");
    } else {
        response.sendRedirect("list.jsp");
    }
%>