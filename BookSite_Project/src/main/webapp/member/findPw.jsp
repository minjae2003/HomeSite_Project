<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.FindLimiter" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String error = null;
    int locked = FindLimiter.lockedMinutes(session);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (locked > 0) {
            error = "확인에 여러 번 실패해서 " + locked + "분 뒤에 다시 시도할 수 있어요.";
        } else if (id == null || id.trim().isEmpty() || name == null || name.trim().isEmpty()
                   || email == null || email.trim().isEmpty()) {
            error = "아이디, 이름, 이메일을 모두 입력해 주세요.";
        } else if (MemberDAO.getInstance().matchForReset(id, name, email)) {
            // 본인 확인 성공 → 10분 동안 이 아이디의 비밀번호 재설정 허가
            FindLimiter.success(session);
            FindLimiter.allowReset(session, id.trim());
            response.sendRedirect("resetPw.jsp");
            return;
        } else {
            int left = FindLimiter.fail(session);
            error = left > 0
                ? "입력하신 정보와 일치하는 회원이 없어요. (남은 시도 " + left + "회)"
                : "확인에 여러 번 실패해서 10분 동안 찾기를 이용할 수 없어요.";
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>비밀번호 찾기 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/index.css">
    <link rel="stylesheet" href="../css/member.css">
    <link rel="stylesheet" href="../css/find.css">
</head>
<body>

    <jsp:include page="/module/header.jsp" flush="false"/>

    <section>
        <div id="main_content">
            <div id="join_box">
                <h2>아이디 / 비밀번호 찾기</h2>

                <div class="find-tabs">
                    <a href="findId.jsp" class="find-tab">아이디 찾기</a>
                    <a href="findPw.jsp" class="find-tab active">비밀번호 찾기</a>
                </div>

                <form name="find_form" method="post" action="findPw.jsp" onsubmit="return checkFind(this);">
                    <p class="find-desc"><b>아이디, 이름, 이메일</b>이 모두 일치하면 새 비밀번호를 설정할 수 있어요.</p>

                    <% if (error != null) { %><div class="find-error"><%= esc(error) %></div><% } %>

                    <div class="form-group">
                        <label for="id">아이디</label>
                        <input type="text" id="id" name="id" maxlength="50" value="<%= esc(id) %>" placeholder="아이디 입력">
                    </div>
                    <div class="form-group">
                        <label for="name">이름</label>
                        <input type="text" id="name" name="name" maxlength="50" value="<%= esc(name) %>" placeholder="이름 입력">
                    </div>
                    <div class="form-group">
                        <label for="email">이메일</label>
                        <input type="email" id="email" name="email" maxlength="100" value="<%= esc(email) %>" placeholder="example@email.com">
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn-submit">본인 확인</button>
                    </div>
                    <p class="find-note">이메일을 등록하지 않은 계정은 찾을 수 없어요. 관리자에게 문의해 주세요.</p>
                </form>

                <div class="find-links">
                    <a href="loginForm.jsp">로그인</a><span>|</span><a href="memberForm.jsp">회원가입</a>
                </div>
            </div>
        </div>
    </section>

    <jsp:include page="/module/footer.jsp" flush="false"/>

<script>
function checkFind(f) {
    if (!f.id.value.trim()) { alert("아이디를 입력하세요!"); f.id.focus(); return false; }
    if (!f.name.value.trim()) { alert("이름을 입력하세요!"); f.name.focus(); return false; }
    if (!f.email.value.trim()) { alert("이메일을 입력하세요!"); f.email.focus(); return false; }
    return true;
}
</script>
</body>
</html>