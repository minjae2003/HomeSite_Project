<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<% request.setCharacterEncoding("utf-8"); %>
<%
    String id = request.getParameter("id");
    MemberDAO mdao = MemberDAO.getInstance();
    int check = mdao.idCheck(id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>아이디 중복 체크</title>
<style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
        font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
    }
    body {
        padding: 24px 20px;
        background-color: #ffffff;
    }
    h3 {
        font-size: 16px;
        font-weight: 700;
        color: #111827;
        margin-bottom: 20px;
        border-left: 4px solid #f95e07;
        padding-left: 8px;
    }
    .msg-box {
        margin: 20px 0 24px;
        font-size: 14px;
        color: #374151;
        line-height: 1.6;
        list-style: none;
        text-align: center;
    }
    .highlight {
        font-weight: 700;
        color: #f95e07;
    }
    .btn-close {
        width: 100%;
        padding: 10px;
        background-color: #4b5563;
        color: #ffffff;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background-color 0.2s;
    }
    .btn-close:hover {
        background-color: #1f2937;
    }
</style>
</head>
<body>

<h3>아이디 중복 체크</h3>

<ul class="msg-box">
<% if(id == null || id.trim().equals("")) { %>
    <li>아이디를 입력해 주세요.</li>
<% } else {
      if(check == 1) { %>
        <li>"<span class="highlight"><%=id %></span>"는 이미 사용 중인 아이디입니다.</li>
        <li>다른 아이디를 입력해 주세요.</li>
   <% } else { %>
        <li>"<span class="highlight"><%=id %></span>"는 사용 가능한 아이디입니다.</li>
   <% }
} %>
</ul>

<button type="button" class="btn-close" onclick="self.close()">닫기</button>

</body>
</html>