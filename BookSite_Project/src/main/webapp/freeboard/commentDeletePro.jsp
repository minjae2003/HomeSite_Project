<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.CommentDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");
    if (sessionUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    // POST만 허용 (링크/이미지 태그로 몰래 호출되는 것 방지)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    // 입력값 검증 - 숫자가 아니면 거부 (NumberFormatException 500 에러 방지)
    String commentNumParam = request.getParameter("commentNum");
    String boardNumParam = request.getParameter("boardNum");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    if (commentNumParam == null || !commentNumParam.matches("\\d{1,9}")
            || boardNumParam == null || !boardNumParam.matches("\\d{1,9}")) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        return;
    }
    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";
    category = (category == null) ? "ALL" : category.trim().toUpperCase();
    if (!java.util.Arrays.asList("ALL", "BEST", "FREE", "TIP", "QNA", "RECIPE").contains(category)) category = "ALL";

    int commentNum = Integer.parseInt(commentNumParam);
    int boardNum = Integer.parseInt(boardNumParam);

    // 본인 또는 관리자만 삭제 (권한 확인은 DAO의 WHERE 절에서)
    boolean deleted = CommentDAO.getInstance()
            .deleteComment(commentNum, boardNum, sessionUserId, "ADMIN".equals(sessionRole));

    if (!deleted) {
        out.println("<script>alert('삭제 권한이 없거나 이미 삭제된 댓글입니다.'); history.back();</script>");
        return;
    }

    response.sendRedirect("content.jsp?num=" + boardNum + "&pageNum=" + pageNum + "&category=" + category);
%>
