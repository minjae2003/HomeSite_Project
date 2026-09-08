<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO, qna.QnaDTO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String writer = request.getParameter("writer");
    String subject = request.getParameter("subject");
    String content = request.getParameter("content");
    String secret = request.getParameter("secret");
    if (secret == null) secret = "N";

    QnaDTO article = new QnaDTO();
    article.setWriter(writer);
    article.setSubject(subject);
    article.setContent(content);
    article.setSecret(secret);

    QnaDAO dao = QnaDAO.getInstance();
    dao.insertArticle(article);

    response.sendRedirect("qnaList.jsp");
%>