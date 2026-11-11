<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.CommentDAO, board.CommentVO" %>

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

    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");

    if (sessionUserId == null || sessionUserId.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('로그인이 필요한 서비스입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    String boardNumParam = request.getParameter("boardNum");
    String content = request.getParameter("content");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";
    category = (category == null) ? "ALL" : category.trim().toUpperCase();
    if (!java.util.Arrays.asList("ALL", "BEST", "FREE", "TIP", "QNA", "RECIPE").contains(category)) category = "ALL";
    if (boardNumParam == null || !boardNumParam.trim().matches("\\d{1,9}")) {
        response.sendRedirect("list.jsp");
        return;
    }
    boardNumParam = boardNumParam.trim();

    if (content != null && !content.trim().isEmpty()) {
            // 금칙어 검사 (관리자 제외)
            if (!"ADMIN".equals(session.getAttribute("role"))) {
                String badWord = filter.WordFilter.find(content);
                if (badWord != null) {
                    out.println("<script>alert('" + util.HtmlUtil.js(filter.WordFilter.message(badWord)) + "'); history.back();</script>");
                    return;
                }
            }
        int boardNum = Integer.parseInt(boardNumParam);

        CommentVO comment = new CommentVO();
        comment.setBoardNum(boardNum);
        comment.setWriter(sessionUserNick != null ? sessionUserNick : sessionUserId);
        comment.setWriterId(sessionUserId);
        comment.setWriterNickname(sessionUserNick);
        comment.setContent(content);

        CommentDAO dao = CommentDAO.getInstance();
        dao.insertComment(comment);
    }

    response.sendRedirect("content.jsp?num=" + boardNumParam + "&pageNum=" + pageNum + "&category=" + category);
%>