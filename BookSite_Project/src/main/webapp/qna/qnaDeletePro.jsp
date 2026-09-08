<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO" %>
<%
    int num = Integer.parseInt(request.getParameter("num"));
    String pageNum = request.getParameter("pageNum");

    QnaDAO dao = QnaDAO.getInstance();
    int result = dao.deleteQnaArticle(num);

    if (result > 0) {
%>
        <script>
            alert("게시글이 삭제되었습니다.");
            location.href = "qnaList.jsp?pageNum=<%= pageNum %>";
        </script>
<%
    } else {
%>
        <script>
            alert("삭제 처리 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>