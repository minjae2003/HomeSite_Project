<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO, qna.QnaDTO" %>
<%
    request.setCharacterEncoding("UTF-8");

    int num = Integer.parseInt(request.getParameter("num"));
    String pageNum = request.getParameter("pageNum");
    String subject = request.getParameter("subject");
    String content = request.getParameter("content");

    QnaDTO article = new QnaDTO();
    article.setNum(num);
    article.setSubject(subject);
    article.setContent(content);

    QnaDAO dao = QnaDAO.getInstance();
    int result = dao.updateQnaArticle(article);

    if (result > 0) {
%>
        <script>
            alert("글이 성공적으로 수정되었습니다.");
            location.href = "qnaDetail.jsp?num=<%= num %>&pageNum=<%= pageNum %>";
        </script>
<%
    } else {
%>
        <script>
            alert("글 수정에 실패했습니다.");
            history.back();
        </script>
<%
    }
%>