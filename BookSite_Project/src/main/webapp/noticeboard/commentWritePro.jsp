<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.CommentDAO, board.CommentVO" %>

<%
    request.setCharacterEncoding("UTF-8");

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

    if (pageNum == null) pageNum = "1";
    if (category == null) category = "ALL";

    if (boardNumParam != null && content != null && !content.trim().isEmpty()) {
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