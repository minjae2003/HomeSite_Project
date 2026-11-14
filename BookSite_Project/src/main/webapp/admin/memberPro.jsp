<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, mypage.ProfileDAO, java.io.File, java.util.List" %>
<%
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("members.jsp");
        return;
    }
    String me = (String) session.getAttribute("id");
    if (me == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    String action = request.getParameter("action");
    String id = request.getParameter("id");
    String back = request.getParameter("back");
    // 돌아갈 목록 조건은 정해진 형식만 허용
    if (back == null || !back.matches("q=[^&<>\"']*&filter=(ALL|SUSPENDED|ADMIN)(&pageNum=\\d{1,6})?")) back = "";
    String backUrl = "members.jsp" + (back.isEmpty() ? "" : "?" + back);

    MemberDAO dao = MemberDAO.getInstance();
    MemberVO target = (id == null) ? null : dao.getMember(id);
    if (target == null) {
        out.println("<script>alert('존재하지 않는 회원입니다.'); location.href='" + backUrl + "';</script>");
        return;
    }
    // 관리자 계정과 본인 계정은 정지·탈퇴 대상이 아님
    if ("ADMIN".equals(target.getRole()) || target.getId().equals(me)) {
        out.println("<script>alert('관리자 계정은 정지하거나 탈퇴시킬 수 없습니다.'); location.href='" + backUrl + "';</script>");
        return;
    }

    String msg;
    if ("suspend".equals(action)) {
        String daysStr = request.getParameter("days");
        int days = (daysStr != null && daysStr.matches("0|1|3|7|30")) ? Integer.parseInt(daysStr) : 7;
        String reason = request.getParameter("reason");
        reason = reason == null ? "" : reason.trim();
        if (reason.isEmpty() || reason.length() > 200) {
            out.println("<script>alert('정지 사유를 1~200자로 입력해 주세요.'); history.back();</script>");
            return;
        }
        msg = dao.suspend(target.getId(), days, reason) ? "이용 정지했습니다." : "처리 중 오류가 발생했습니다.";
    } else if ("unsuspend".equals(action)) {
        msg = dao.unsuspend(target.getId()) ? "정지를 해제했습니다." : "처리 중 오류가 발생했습니다.";
    } else if ("delete".equals(action)) {
        String profileImg = ProfileDAO.getInstance().get(target.getId()).getProfileImg();
        List<String> savedNames = dao.deleteMember(target.getId());
        if (savedNames == null) {
            msg = "탈퇴 처리 중 오류가 발생했습니다.";
        } else {
            String uploadDir = util.UploadDir.root(application).getPath();
            for (String name : savedNames) {
                if (name == null) continue;
                File f = new File(uploadDir, name);
                if (f.exists()) f.delete();
            }
            if (profileImg != null && !profileImg.contains("/") && !profileImg.contains("\\") && !profileImg.contains("..")) {
                File pf = new File(util.UploadDir.profile(application).getPath(), profileImg);
                if (pf.exists()) pf.delete();
            }
            msg = "강제 탈퇴 처리했습니다.";
        }
    } else {
        response.sendRedirect(backUrl);
        return;
    }
    out.println("<script>alert('" + msg + "'); location.href='" + backUrl + "';</script>");
%>
