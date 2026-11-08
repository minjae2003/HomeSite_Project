<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, member.LoginLimiter, util.PasswordUtil" %>
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
    String phoneRaw = request.getParameter("phone");
    String digits = (phoneRaw == null) ? "" : phoneRaw.replaceAll("[^0-9]", "");
    String phone = null;
    if (!digits.isEmpty()) {
        boolean seoul = digits.startsWith("02");
        boolean valid = digits.startsWith("0") &&
                (seoul ? (digits.length() == 9 || digits.length() == 10)
                       : (digits.length() == 10 || digits.length() == 11));
        if (!valid) {
            out.println("<script>alert('전화번호 형식이 올바르지 않습니다.'); history.back();</script>");
            return;
        }
        int head = seoul ? 2 : 3;
        int tail = digits.length() - 4;
        phone = digits.substring(0, head) + "-" + digits.substring(head, tail) + "-" + digits.substring(tail);
    }
    if (!newPass.equals(newPassConfirm)) {
        out.println("<script>alert('새 비밀번호가 서로 일치하지 않습니다.'); history.back();</script>");
        return;
    }
    if (!newPass.isEmpty()) {
        String policyError = PasswordUtil.checkPolicy(newPass, sessionUserId);
        if (policyError != null) {
            out.println("<script>alert('" + policyError + "'); history.back();</script>");
            return;
        }
    }

    MemberDAO dao = MemberDAO.getInstance();
    int locked = LoginLimiter.lockedMinutes(request, sessionUserId);
    if (locked > 0) {
        out.println("<script>alert('비밀번호 확인 실패가 너무 많아요. " + locked + "분 뒤에 다시 시도해 주세요.'); history.back();</script>");
        return;
    }
    if (currentPass == null || dao.userCheck(sessionUserId, currentPass) != 1) {
        LoginLimiter.fail(request, sessionUserId);
        out.println("<script>alert('현재 비밀번호가 일치하지 않습니다.'); history.back();</script>");
        return;
    }
    LoginLimiter.success(request, sessionUserId);

    MemberVO member = new MemberVO();
    member.setId(sessionUserId);
    member.setNickname(nickname);
    member.setName(name);
    member.setEmail(email);
    member.setPhone(phone);

    if (dao.updateMember(member, newPass)) {
        session.setAttribute("nickname", nickname);
        out.println("<script>alert('회원정보가 수정되었습니다.'); location.href='../mypage/account.jsp';</script>");
    } else {
        out.println("<script>alert('회원정보 수정에 실패했습니다. 잠시 후 다시 시도해 주세요.'); history.back();</script>");
    }
%>
