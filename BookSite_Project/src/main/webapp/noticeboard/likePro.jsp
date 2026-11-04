<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 상태를 바꾸는 요청은 POST만 허용 (GET 링크/이미지 태그로 몰래 호출되는 것 방지, 토큰 검사는 CsrfFilter)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) sessionUserId = (String) session.getAttribute("userId");
    if (sessionUserId == null) sessionUserId = (String) session.getAttribute("memberId");

    String numParam = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    // <script> 안에 그대로 출력되므로 숫자/허용된 값만 사용 (반사형 XSS 방지)
    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";
    category = (category == null) ? "ALL" : category.trim().toUpperCase();
    if (!java.util.Arrays.asList("ALL", "FIX", "NORMAL").contains(category)) category = "ALL";

    if (sessionUserId == null || sessionUserId.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('로그인이 필요한 서비스입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    if (numParam != null && numParam.trim().matches("\\d{1,9}")) {
        int num = Integer.parseInt(numParam.trim());
        BoardDAO dao = BoardDAO.getInstance();
        
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