<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.sql.Timestamp" %>

<%
    request.setCharacterEncoding("utf-8");

    // Form 파라미터 직접 수령 및 객체 생성
    String id = request.getParameter("id");
    String pass = request.getParameter("pass");
    String name = request.getParameter("name");

    MemberVO member = new MemberVO();
    member.setId(id);
    member.setPass(pass);
    member.setName(name);
    member.setReg_date(new Timestamp(System.currentTimeMillis()));

    MemberDAO mdao = MemberDAO.getInstance();
    mdao.insertMember(member);
%>

<script>
    alert("회원가입이 완료되었습니다! 로그인해 주세요.");
    location.href = "${pageContext.request.contextPath}/member/loginForm.jsp";
</script>