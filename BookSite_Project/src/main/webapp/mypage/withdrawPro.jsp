<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, member.LoginLimiter, java.util.List,mypage.ProfileDAO, java.io.File" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("account.jsp");
        return;
    }

    MemberDAO dao = MemberDAO.getInstance();
    MemberVO member = dao.getMember(sessionUserId);
    if (member == null) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/main/index.jsp");
        return;
    }

    if ("ADMIN".equals(member.getRole())) {
        out.println("<script>alert('관리자 계정은 탈퇴할 수 없습니다.'); location.href='account.jsp';</script>");
        return;
    }

    // 본인 확인 (로그인과 같은 시도 제한 적용 - 세션을 탈취한 사람이 비밀번호를 대입해 보는 것 방지)
    int locked = LoginLimiter.lockedMinutes(request, sessionUserId);
    if (locked > 0) {
        out.println("<script>alert('비밀번호 확인 실패가 너무 많아요. " + locked + "분 뒤에 다시 시도해 주세요.'); history.back();</script>");
        return;
    }
    String password = request.getParameter("password");
    if (password == null || dao.userCheck(sessionUserId, password) != 1) {
        LoginLimiter.fail(request, sessionUserId);
        out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
        return;
    }
    LoginLimiter.success(request, sessionUserId);
    String profileImg = ProfileDAO.getInstance().get(sessionUserId).getProfileImg();
    List<String> savedNames = dao.deleteMember(sessionUserId);
    if (savedNames == null) {
        out.println("<script>alert('탈퇴 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); location.href='account.jsp';</script>");
        return;
    }

    String uploadDir = application.getRealPath("/uploads");
    for (String name : savedNames) {
        if (name == null) continue;
        File f = new File(uploadDir, name);
        if (f.exists()) f.delete();
    }
    if (profileImg != null && !profileImg.contains("/") && !profileImg.contains("\\") && !profileImg.contains("..")) {
        File pf = new File(application.getRealPath("/uploads/profile"), profileImg);
        if (pf.exists()) pf.delete();
    }
    session.invalidate();
    out.println("<script>alert('회원 탈퇴가 완료되었습니다. 그동안 이용해 주셔서 감사합니다.'); location.href='../main/index.jsp';</script>");
%>