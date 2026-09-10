<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String pass = request.getParameter("pass");
    
    // loginForm.jsp의 input name이 'passwd' 또는 'password'인 경우 예외 처리
    if (pass == null || pass.trim().isEmpty()) {
        pass = request.getParameter("passwd");
    }
    if (pass == null || pass.trim().isEmpty()) {
        pass = request.getParameter("password");
    }

    // 앞뒤 공백 제거
    if (id != null) id = id.trim();
    if (pass != null) pass = pass.trim();

    MemberDAO dao = MemberDAO.getInstance();
    int check = dao.userCheck(id, pass);

    if (check == 1) {
        MemberVO member = dao.getMember(id);
        if (member != null) {
            session.setAttribute("id", member.getId());
            session.setAttribute("nickname", member.getNickname());
            session.setAttribute("role", member.getRole());

            out.println("<script>alert('" + member.getNickname() + "님 환영합니다!'); location.href='../freeboard/list.jsp';</script>");
        } else {
            out.println("<script>alert('회원 정보를 불러오지 못했습니다.'); history.go(-1);</script>");
        }
    } else if (check == 0) {
        out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.go(-1);</script>");
    } else {
        out.println("<script>alert('존재하지 않는 아이디입니다.'); history.go(-1);</script>");
    }
%>