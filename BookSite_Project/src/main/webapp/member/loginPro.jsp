<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil" %>
<%@ page import="member.MemberDAO, member.LoginLimiter" %>
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
    
    if (pass == null || pass.trim().isEmpty()) {
        pass = request.getParameter("passwd");
    }
    if (pass == null || pass.trim().isEmpty()) {
        pass = request.getParameter("password");
    }

    if (id != null) id = id.trim();

    // 로그인 시도 제한: 아이디별 15분에 5번, IP별 15분에 20번 틀리면 잠시 잠금 (무작위 대입 방지)
    int locked = LoginLimiter.lockedMinutes(request, id);
    if (locked > 0) {
        out.println("<script>alert('로그인 실패가 너무 많아요. " + locked + "분 뒤에 다시 시도해 주세요.'); history.go(-1);</script>");
        return;
    }

    MemberDAO dao = MemberDAO.getInstance();
    int check = dao.userCheck(id, pass);
    if (check == 1) {
        LoginLimiter.success(request, id);
    } else {
        int left = LoginLimiter.fail(request, id);
        if (left == 0) {
            out.println("<script>alert('로그인 실패가 너무 많아요. 잠시 뒤에 다시 시도해 주세요.'); history.go(-1);</script>");
            return;
        }
    }

    if (check == 1) {
        MemberVO member = dao.getMember(id);
        if (member != null && member.isSuspended()) {
            String reason = member.getSuspendReason() == null || member.getSuspendReason().isEmpty() ? "운영정책 위반" : member.getSuspendReason();
            out.println("<script>alert('이용이 정지된 계정입니다.\\n\\n정지 기간: " + HtmlUtil.js(member.getSuspendUntilText())
                    + "\\n사유: " + HtmlUtil.js(reason) + "\\n\\n이의가 있으면 사이트 하단 이메일로 문의해 주세요.'); history.go(-1);</script>");
            return;
        }
        if (member != null) {
            // 세션 고정 공격 방지: 로그인 전 세션은 버리고 새 세션(새 세션 ID, 새 CSRF 토큰)으로 로그인 처리
            session.invalidate();
            HttpSession loginSession = request.getSession(true);
            loginSession.setAttribute("id", member.getId());
            loginSession.setAttribute("nickname", member.getNickname());
            loginSession.setAttribute("role", member.getRole());

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