<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO, qna.QnaDTO, java.text.SimpleDateFormat" %>
<%
    int num = Integer.parseInt(request.getParameter("num"));
    QnaDAO dao = QnaDAO.getInstance();

    dao.updateReadCount(num);
    QnaDTO article = dao.getQnaArticle(num);

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>QnA 상세보기</title>
<link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
<%@ include file="../module/header.jsp" %>

<div class="container">
    <h2>게시글 상세</h2>
    <% if (article != null) { %>
    <table border="1" class="qna-table" width="100%">
        <tr>
            <th width="15%">글번호</th>
            <td width="35%"><%= article.getNum() %></td>
            <th width="15%">조회수</th>
            <td width="35%"><%= article.getReadcount() %></td>
        </tr>
        <tr>
            <th>작성자</th>
            <td><%= article.getWriter() %></td>
            <th>작성일</th>
            <td><%= sdf.format(article.getReg_date()) %></td>
        </tr>
        <tr>
            <th>제목</th>
            <td colspan="3"><%= article.getSubject() %></td>
        </tr>
        <tr>
            <th>내용</th>
            <td colspan="3" style="height:150px; vertical-align:top;"><%= article.getContent().replaceAll("\n", "<br>") %></td>
        </tr>
    </table>
    <br>
    <div style="text-align: center;">
        <input type="button" value="목록으로" onclick="location.href='qnaList.jsp'">
    </div>
    <% } %>
</div>
</body>
</html>