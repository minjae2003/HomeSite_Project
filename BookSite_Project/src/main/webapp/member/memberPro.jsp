<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    try {
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
        member.setNickname(nickname);
        member.setEmail(email);

        MemberDAO dao = MemberDAO.getInstance();

        if (dao.idCheck(id) == 1) {
            out.println("<script>alert('이미 사용 중인 아이디입니다.'); history.go(-1);</script>");
        } else {
            dao.insertMember(member);
            out.println("<script>alert('회원가입 성공!'); location.href='loginForm.jsp';</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('DB 에러 발생: " + e.getMessage().replace("'", "") + "'); history.go(-1);</script>");
    }
%>