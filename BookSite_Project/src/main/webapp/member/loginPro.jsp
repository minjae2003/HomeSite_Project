<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil" %>
<%@ page import="member.MemberDAO, member.MemberVO, member.LoginLimiter" %>
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
    if (pass == null || pass.isEmpty()) pass = request.getParameter("passwd");
    if (pass == null || pass.isEmpty()) pass = request.getParameter("password");

    // 아이디만 앞뒤 공백 제거 (비밀번호는 입력한 그대로 해시와 비교해야 하므로 손대지 않음)
    if (id != null) id = id.trim();

    if (id == null || id.isEmpty() || pass == null || pass.isEmpty()) {
        out.println("<script>alert('아이디와 비밀번호를 입력해 주세요.'); history.go(-1);</script>");
        return;
    }

    // 1) 시도 횟수 제한 - 잠겨 있으면 비밀번호 확인 자체를 하지 않음
    int locked = LoginLimiter.lockedMinutes(request, id);
    if (locked > 0) {
        out.println("<script>alert('로그인 실패가 너무 많아요. " + locked + "분 뒤에 다시 시도해 주세요.'); history.go(-1);</script>");
        return;
    }

    MemberDAO dao = MemberDAO.getInstance();
    int check = dao.userCheck(id, pass);
    MemberVO member = (check == 1) ? dao.getMember(id) : null;

    if (member != null) {
        LoginLimiter.success(request, id);

        // 2) 세션 고정 공격 방지 - 로그인 전에 쓰던 세션을 버리고 새 세션 ID를 발급
        //    (공격자가 미리 심어 둔 세션 ID로 피해자가 로그인해도, 공격자는 로그인된 세션을 얻지 못함)
        session.invalidate();
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("id", member.getId());
        newSession.setAttribute("nickname", member.getNickname());
        newSession.setAttribute("role", member.getRole());

        out.println("<script>alert('" + HtmlUtil.js(member.getNickname()) + "님 환영합니다!'); location.href='../main/index.jsp';</script>");
        return;
    }

    // 3) 실패 - 아이디가 없는 경우와 비밀번호가 틀린 경우를 같은 메시지로 (아이디 존재 여부 노출 방지)
    int left = LoginLimiter.fail(request, id);
    String msg = left > 0
        ? "아이디 또는 비밀번호가 올바르지 않습니다. (남은 시도 " + left + "회)"
        : "로그인 실패가 너무 많아요. 10분 뒤에 다시 시도해 주세요.";
    out.println("<script>alert('" + msg + "'); history.go(-1);</script>");
%>
