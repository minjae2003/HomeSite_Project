<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.sql.Timestamp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String pass = request.getParameter("pass");
    if (pass == null) pass = request.getParameter("password");
    
    String name = request.getParameter("name");
    String nickname = request.getParameter("nickname");
    String email = request.getParameter("email");

    MemberVO member = new MemberVO();
    member.setId(id);
    member.setPassword(pass);
    member.setName(name);
    member.setNickname(nickname != null ? nickname : name);
    member.setEmail(email != null ? email : "");
    member.setRegDate(new Timestamp(System.currentTimeMillis()));

    MemberDAO dao = MemberDAO.getInstance();
    
    if (dao.idCheck(id) == 1) {
        out.println("<script>alert('이미 존재하는 아이디입니다.'); history.go(-1);</script>");
    } else {
        dao.insertMember(member);
        out.println("<script>alert('회원가입이 완료되었습니다.'); location.href='loginForm.jsp';</script>");
    }
%>