<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>
<%@ page import="board.BoardVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String writerId = (String) session.getAttribute("id");
    String writerNickname = (String) session.getAttribute("nickname");

    if (writerId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    BoardVO board = new BoardVO();
    board.setBoardType("FREE");
    board.setCategory(request.getParameter("category"));
    board.setWriterId(writerId);
    board.setWriterNickname(writerNickname != null ? writerNickname : writerId);
    board.setSubject(request.getParameter("subject"));
    board.setContent(request.getParameter("content"));

    BoardDAO dao = BoardDAO.getInstance();
    dao.insertBoard(board);

    response.sendRedirect("list.jsp");
%>