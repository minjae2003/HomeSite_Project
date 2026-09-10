<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%
    String id = request.getParameter("id");
    MemberDAO mdao = MemberDAO.getInstance();
    int check = mdao.idCheck(id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아이디 중복 확인</title>
</head>
<body>
    <% if (check == 1) { %>
        <p style="color: red;">이미 사용 중인 아이디입니다.</p>
    <% } else { %>
        <p style="color: green;">사용 가능한 아이디입니다.</p>
    <% } %>
</body>
</html>