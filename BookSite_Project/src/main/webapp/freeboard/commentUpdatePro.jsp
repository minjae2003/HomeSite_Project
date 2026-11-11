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

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

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

    String content = request.getParameter("content");
    content = (content == null) ? "" : content.trim();
    if (content.isEmpty()) {
        out.println("<script>alert('댓글 내용을 입력해 주세요.'); history.back();</script>");
        return;
    }
    // 금칙어 검사 (관리자 제외)
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        String badWord = filter.WordFilter.find(content);
        if (badWord != null) {
            out.println("<script>alert('" + util.HtmlUtil.js(filter.WordFilter.message(badWord)) + "'); history.back();</script>");
            return;
        }
    }
    if (content.length() > 1000) {
        out.println("<script>alert('댓글은 1000자까지 입력할 수 있습니다.'); history.back();</script>");
        return;
    }

    boolean updated = CommentDAO.getInstance()
            .updateComment(commentNum, boardNum, sessionUserId, "ADMIN".equals(sessionRole), content);

    if (!updated) {
        out.println("<script>alert('수정 권한이 없거나 삭제된 댓글입니다.'); history.back();</script>");
        return;
    }

    response.sendRedirect("content.jsp?num=" + boardNum + "&pageNum=" + pageNum + "&category=" + category);
%>