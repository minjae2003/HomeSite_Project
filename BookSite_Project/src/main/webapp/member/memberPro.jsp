<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>

<%
    request.setCharacterEncoding("UTF-8");

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
        id = id.trim();
        name = name.trim();
        // 닉네임은 필수 (2~50자) - 비어 있으면 실명이 대신 저장되지 않도록 여기서 막음
        String nickname = request.getParameter("nickname");
        nickname = (nickname == null) ? "" : nickname.trim();
        if (nickname.length() < 2 || nickname.length() > 50) {
            out.println("<script>alert('닉네임은 2~50자로 입력해 주세요.'); history.go(-1);</script>");
            return;
        }
        // 이메일은 선택 사항: 비어 있으면 빈 값으로 저장, 입력했으면 형식 검사
        String email = request.getParameter("email");
        email = (email == null) ? "" : email.trim();
        if (!email.isEmpty() && (email.length() > 100 || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))) {
            out.println("<script>alert('이메일 형식이 올바르지 않습니다.'); history.go(-1);</script>");
            return;
        }

        // 전화번호는 선택 사항: 숫자만 추출해 검사한 뒤 010-1234-5678 형식으로 통일
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
            out.println("<script>alert('회원가입 성공!'); location.href='loginForm.jsp';</script>");
        } else {
            out.println("<script>alert('회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); history.go(-1);</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('DB 에러 발생: " + e.getMessage().replace("'", "") + "'); history.go(-1);</script>");
    }
%>