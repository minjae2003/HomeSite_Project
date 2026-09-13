<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String numStr = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");
    String subject = request.getParameter("subject");
    String content = request.getParameter("content");
    String noticeType = request.getParameter("noticeType");

    String sessionRole = (String) session.getAttribute("role");

    if (numStr != null && subject != null && content != null) {
        int num = Integer.parseInt(numStr);

        BoardDAO dao = BoardDAO.getInstance();

        if (!"ADMIN".equals(sessionRole)) {
            BoardVO original = dao.getBoardDetail(num);
            noticeType = (original != null) ? original.getNoticeType() : "NORMAL";
        }
        if (noticeType == null || noticeType.trim().isEmpty()) {
            noticeType = "NORMAL";
        }

        BoardVO board = new BoardVO();
        board.setNum(num);
        board.setSubject(subject);
        board.setContent(content);
        board.setNoticeType(noticeType);

        dao.updateNotice(board);

        out.println("<script>alert('공지사항이 수정되었습니다.'); location.href='content.jsp?num=" + num + "&pageNum=" + pageNum + "&category=" + category + "';</script>");
    } else {
        out.println("<script>alert('잘못된 요청입니다.'); history.go(-1);</script>");
    }
%>