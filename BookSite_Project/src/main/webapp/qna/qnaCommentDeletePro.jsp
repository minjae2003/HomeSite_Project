<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO" %>
<%
    int c_num = Integer.parseInt(request.getParameter("c_num"));
    int num = Integer.parseInt(request.getParameter("num"));
    String pageNum = request.getParameter("pageNum");

    QnaDAO dao = QnaDAO.getInstance();
    int result = dao.deleteQnaComment(c_num);
    if (result > 0) {
%>
        <script>
            alert("댓글이 삭제되었습니다.");
            location.href = "qnaDetail.jsp?num=<%= num %>&pageNum=<%= pageNum %>";
        </script>
<%
    } else {
%>
        <script>
            alert("댓글 삭제에 실패했습니다.");
            history.back();
        </script>
<%
    }
%>