<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>
<%
    // 관리자 전용: 자유게시판 글 상단 고정 / 해제 (POST + CSRF 토큰은 CsrfFilter에서 검사)
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        out.println("<script>alert('관리자만 사용할 수 있습니다.'); history.back();</script>");
        return;
    }

    String numParam = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");
    if (numParam == null || !numParam.matches("\\d{1,9}")) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        return;
    }
    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";
    category = (category == null) ? "ALL" : category.trim().toUpperCase();
    if (!java.util.Arrays.asList("ALL", "BEST", "FREE", "TIP", "QNA", "RECIPE").contains(category)) category = "ALL";

    int num = Integer.parseInt(numParam);
    boolean pin = "pin".equals(request.getParameter("action"));

    if (!BoardDAO.getInstance().setPinned(num, pin)) {
        out.println("<script>alert('처리하지 못했습니다. 이미 삭제된 글이거나 공지사항 글입니다.'); history.back();</script>");
        return;
    }
    out.println("<script>alert('" + (pin ? "게시글을 맨 위에 고정했습니다." : "고정을 해제했습니다.") + "'); location.href='content.jsp?num=" + num + "&pageNum=" + pageNum + "&category=" + category + "';</script>");
%>
