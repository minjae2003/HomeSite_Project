<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");

    // writeForm.jsp를 거치지 않고 writePro.jsp로 직접 요청을 보내는 우회 접근 차단
    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");
    if (sessionUserNick == null) sessionUserNick = sessionUserId;
    if (sessionUserNick == null) sessionUserNick = "익명";

    String category = request.getParameter("category");
    String subject = request.getParameter("subject");
    String content = request.getParameter("content");

    if (category == null || category.trim().isEmpty()) {
        category = "FREE";
    }

    if (subject != null && content != null && !subject.trim().isEmpty()) {
        BoardVO article = new BoardVO();
        article.setWriter(sessionUserNick);
        article.setWriterId(sessionUserId);
        article.setWriterNickname(sessionUserNick);
        article.setCategory(category);
        article.setSubject(subject);
        article.setContent(content);

        BoardDAO dao = BoardDAO.getInstance();
        dao.insertArticle(article);

        response.sendRedirect("list.jsp?category=" + category);
    } else {
        out.println("<script>alert('제목과 내용을 입력해 주세요.'); history.go(-1);</script>");
    }
%>