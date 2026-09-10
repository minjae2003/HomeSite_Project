<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String pass = request.getParameter("pass");
    if (pass == null) pass = request.getParameter("password");

    MemberDAO dao = MemberDAO.getInstance();
    int check = dao.userCheck(id, pass);

    if (check == 1) {
        MemberVO member = dao.getMember(id);
        session.setAttribute("id", member.getId());
        session.setAttribute("nickname", member.getNickname());
        session.setAttribute("role", member.getRole());

        out.println("<script>alert('" + member.getNickname() + "님 환영합니다!'); location.href='../freeboard/list.jsp';</script>");
    } else if (check == 0) {
        out.println("<script>alert('비밀번호가 맞지 않습니다.'); history.go(-1);</script>");
    } else {
        out.println("<script>alert('존재하지 않는 아이디입니다.'); history.go(-1);</script>");
    }
%>