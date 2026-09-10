<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String numStr = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");
    String subject = request.getParameter("subject");
    String content = request.getParameter("content");

    if (numStr != null && subject != null && content != null) {
        int num = Integer.parseInt(numStr);

        BoardVO board = new BoardVO();
        board.setNum(num);
        board.setSubject(subject);
        board.setContent(content);

        BoardDAO dao = BoardDAO.getInstance();
        dao.updateArticle(board);

        out.println("<script>alert('게시글이 수정되었습니다.'); location.href='content.jsp?num=" + num + "&pageNum=" + pageNum + "';</script>");
    } else {
        out.println("<script>alert('잘못된 요청입니다.'); history.go(-1);</script>");
    }
%>