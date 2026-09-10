<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.CommentDAO, board.CommentVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String boardNumStr = request.getParameter("boardNum");
    String pageNum = request.getParameter("pageNum");
    String content = request.getParameter("content");

    String sessionUserId = (String) session.getAttribute("id");
    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");
    if (sessionUserNick == null) sessionUserNick = sessionUserId;
    if (sessionUserNick == null) sessionUserNick = "익명";

    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요한 기능입니다.'); history.go(-1);</script>");
        return;
    }

    if (boardNumStr != null && content != null && !content.trim().isEmpty()) {
        int boardNum = Integer.parseInt(boardNumStr);

        CommentVO comment = new CommentVO();
        comment.setBoardNum(boardNum);
        comment.setWriter(sessionUserNick);
        comment.setWriterId(sessionUserId);
        comment.setContent(content);

        CommentDAO commentDAO = CommentDAO.getInstance();
        commentDAO.insertComment(comment);

        response.sendRedirect("content.jsp?num=" + boardNum + "&pageNum=" + pageNum);
    } else {
        out.println("<script>alert('댓글 내용을 입력해주세요.'); history.go(-1);</script>");
    }
%>