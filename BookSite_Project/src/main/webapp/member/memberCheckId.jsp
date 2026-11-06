<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%
    String id = request.getParameter("id");
    id = (id == null) ? "" : id.trim();
    // 회원가입과 같은 규칙: 영문으로 시작하는 영문/숫자 4~20자
    boolean validId = id.matches("^[A-Za-z][A-Za-z0-9]{3,19}$");
    int check = validId ? MemberDAO.getInstance().idCheck(id) : -1;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>아이디 중복 확인</title>
</head>
<body>
    <% if (!validId) { %>
        <p style="color: red;">아이디는 영문으로 시작하는 4~20자의 영문/숫자만 사용할 수 있습니다.</p>
    <% } else if (check == 1) { %>
        <p style="color: red;">이미 사용 중인 아이디입니다.</p>
    <% } else { %>
        <p style="color: green;">사용 가능한 아이디입니다.</p>
    <% } %>
</body>
</html>