<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.ConsentDAO, util.PasswordUtil" %>
<%@ page import="member.MemberVO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 상태를 바꾸는 요청은 POST만 허용 (GET 링크/이미지 태그로 몰래 호출되는 것 방지, 토큰 검사는 CsrfFilter)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    try {
        String id = request.getParameter("id");
        String pass = request.getParameter("pass");
        if (pass == null) pass = request.getParameter("password");
        String name = request.getParameter("name");
        if (id == null || id.trim().isEmpty() || pass == null || pass.isEmpty()
                || name == null || name.trim().isEmpty()) {
            out.println("<script>alert('아이디, 비밀번호, 이름을 모두 입력해 주세요.'); history.go(-1);</script>");
            return;
        }
        // [필수] 이용약관, 개인정보 수집·이용 동의 확인 (화면 검사를 우회해도 서버에서 다시 막음)
        if (!"Y".equals(request.getParameter("agree_terms")) || !"Y".equals(request.getParameter("agree_privacy"))) {
            out.println("<script>alert('이용약관과 개인정보 수집·이용에 모두 동의해야 가입할 수 있습니다.'); history.go(-1);</script>");
            return;
        }
        id = id.trim();
        name = name.trim();
        if (!id.matches("^[A-Za-z][A-Za-z0-9]{3,19}$")) {
            out.println("<script>alert('아이디는 영문으로 시작하는 4~20자의 영문/숫자만 사용할 수 있습니다.'); history.go(-1);</script>");
            return;
        }
        String policyError = PasswordUtil.checkPolicy(pass, id);
        if (policyError != null) {
            out.println("<script>alert('" + policyError + "'); history.go(-1);</script>");
            return;
        }
        String nickname = request.getParameter("nickname");
        nickname = (nickname == null) ? "" : nickname.trim();
        if (nickname.length() < 2 || nickname.length() > 50) {
            out.println("<script>alert('닉네임은 2~50자로 입력해 주세요.'); history.go(-1);</script>");
            return;
        }
        String badWord = filter.WordFilter.find(nickname + " " + id);
        if (badWord != null) {
            out.println("<script>alert('닉네임이나 아이디에 사용할 수 없는 표현이 있어요.'); history.go(-1);</script>");
            return;
        }
        String email = request.getParameter("email");
        email = (email == null) ? "" : email.trim();
        if (!email.isEmpty() && (email.length() > 100 || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))) {
            out.println("<script>alert('이메일 형식이 올바르지 않습니다.'); history.go(-1);</script>");
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
                out.println("<script>alert('전화번호 형식이 올바르지 않습니다.'); history.go(-1);</script>");
                return;
            }
            int head = seoul ? 2 : 3;
            int tail = digits.length() - 4;
            phone = digits.substring(0, head) + "-" + digits.substring(head, tail) + "-" + digits.substring(tail);
        }
        MemberVO member = new MemberVO();
        member.setId(id);
        member.setPassword(pass);
        member.setName(name);
        member.setNickname(nickname);
        member.setEmail(email);
        member.setPhone(phone);

        MemberDAO dao = MemberDAO.getInstance();

        if (dao.idCheck(id) == 1) {
            out.println("<script>alert('이미 사용 중인 아이디입니다.'); history.go(-1);</script>");
        } else if (dao.insertMember(member)) {
            ConsentDAO.getInstance().agree(id, util.SiteInfo.POLICY_VERSION);
            out.println("<script>alert('회원가입 성공!'); location.href='loginForm.jsp';</script>");
        } else {
            out.println("<script>alert('회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); history.go(-1);</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); history.go(-1);</script>");
    }
%>