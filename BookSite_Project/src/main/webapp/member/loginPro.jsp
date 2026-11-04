<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil" %>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 상태를 바꾸는 요청은 POST만 허용 (GET 링크/이미지 태그로 몰래 호출되는 것 방지, 토큰 검사는 CsrfFilter)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    String id = request.getParameter("id");
    String pass = request.getParameter("pass");
    
    // loginForm.jsp의 input name이 'passwd' 또는 'password'인 경우 예외 처리
    if (pass == null || pass.trim().isEmpty()) {
        pass = request.getParameter("passwd");
    }
    if (pass == null || pass.trim().isEmpty()) {
        pass = request.getParameter("password");
    }

    // 아이디만 앞뒤 공백 제거 (비밀번호는 입력한 그대로 해시와 비교해야 하므로 손대지 않음)
    if (id != null) id = id.trim();

    MemberDAO dao = MemberDAO.getInstance();
    int check = dao.userCheck(id, pass);

    if (check == 1) {
        MemberVO member = dao.getMember(id);
        if (member != null) {
            session.setAttribute("id", member.getId());
            session.setAttribute("nickname", member.getNickname());
            session.setAttribute("role", member.getRole());

            out.println("<script>alert('" + HtmlUtil.js(member.getNickname()) + "님 환영합니다!'); location.href='../main/index.jsp';</script>");
        } else {
            out.println("<script>alert('회원 정보를 불러오지 못했습니다.'); history.go(-1);</script>");
        }
    } else if (check == 0) {
        out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.go(-1);</script>");
    } else {
        out.println("<script>alert('존재하지 않는 아이디입니다.'); history.go(-1);</script>");
    }
%>