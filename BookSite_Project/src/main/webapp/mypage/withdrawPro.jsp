<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, java.util.List,mypage.ProfileDAO, java.io.File" %>
<%
    // 회원 탈퇴 처리 (POST + 현재 비밀번호 확인)
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

    // 관리자 계정은 탈퇴 불가 (사이트 관리자가 사라지는 것 방지)
    if ("ADMIN".equals(member.getRole())) {
        out.println("<script>alert('관리자 계정은 탈퇴할 수 없습니다.'); location.href='account.jsp';</script>");
        return;
    }

    // 본인 확인
    String password = request.getParameter("password");
    if (password == null || dao.userCheck(sessionUserId, password) != 1) {
        out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
        return;
    }
    // 프로필 사진 파일 이름 (DB 행은 CASCADE로 지워지므로 미리 기억)
    String profileImg = ProfileDAO.getInstance().get(sessionUserId).getProfileImg();
    List<String> savedNames = dao.deleteMember(sessionUserId);
    if (savedNames == null) {
        out.println("<script>alert('탈퇴 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); location.href='account.jsp';</script>");
        return;
    }

    // 내 글에 첨부했던 실제 파일 삭제
    String uploadDir = application.getRealPath("/uploads");
    for (String name : savedNames) {
        if (name == null) continue;
        File f = new File(uploadDir, name);
        if (f.exists()) f.delete();
    }
    // 프로필 사진 삭제
    if (profileImg != null && !profileImg.contains("/") && !profileImg.contains("\\") && !profileImg.contains("..")) {
        File pf = new File(application.getRealPath("/uploads/profile"), profileImg);
        if (pf.exists()) pf.delete();
    }
    session.invalidate();
    out.println("<script>alert('회원 탈퇴가 완료되었습니다. 그동안 이용해 주셔서 감사합니다.'); location.href='../main/index.jsp';</script>");
%>