<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginForm.jsp';</script>");
        return;
    }
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("memberupdateForm.jsp");
        return;
    }

    String nickname = request.getParameter("nickname");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String currentPass = request.getParameter("currentPass");
    String newPass = request.getParameter("newPass");
    String newPassConfirm = request.getParameter("newPassConfirm");

    nickname = nickname == null ? "" : nickname.trim();
    name = name == null ? "" : name.trim();
    email = email == null ? "" : email.trim();
    if (newPass == null) newPass = "";
    if (newPassConfirm == null) newPassConfirm = "";

    if (nickname.isEmpty() || name.isEmpty() || email.isEmpty()) {
        out.println("<script>alert('닉네임, 이름, 이메일을 모두 입력해 주세요.'); history.back();</script>");
        return;
    }
    if (nickname.length() > 50 || name.length() > 50 || email.length() > 100 || newPass.length() > 100) {
        out.println("<script>alert('입력값이 너무 깁니다.'); history.back();</script>");
        return;
    }
    if (!newPass.equals(newPassConfirm)) {
        out.println("<script>alert('새 비밀번호가 서로 일치하지 않습니다.'); history.back();</script>");
        return;
    }

    // 본인 확인: 현재 비밀번호 검사 (MemberDAO.userCheck: 1 = 일치)
    MemberDAO dao = MemberDAO.getInstance();
    if (currentPass == null || dao.userCheck(sessionUserId, currentPass) != 1) {
        out.println("<script>alert('현재 비밀번호가 일치하지 않습니다.'); history.back();</script>");
        return;
    }

    MemberVO member = new MemberVO();
    member.setId(sessionUserId);
    member.setNickname(nickname);
    member.setName(name);
    member.setEmail(email);

    if (dao.updateMember(member, newPass)) {
        // 헤더 등에 바로 반영되도록 세션의 닉네임도 갱신
        session.setAttribute("nickname", nickname);
        out.println("<script>alert('회원정보가 수정되었습니다.'); location.href='../mypage/account.jsp';</script>");
    } else {
        out.println("<script>alert('회원정보 수정에 실패했습니다. 잠시 후 다시 시도해 주세요.'); history.back();</script>");
    }
%>
