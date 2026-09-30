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

    // 비밀번호 찾기에서 본인 확인을 통과한 경우에만 (10분 이내) 들어올 수 있음
    String resetId = FindLimiter.resetId(session);
    if (resetId == null) {
        out.println("<script>alert('본인 확인 시간이 지났거나 잘못된 접근입니다.\\n다시 본인 확인을 해 주세요.'); location.href='findPw.jsp';</script>");
        return;
    }

    String error = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String pass = request.getParameter("pass");
        String passConfirm = request.getParameter("pass_confirm");
        if (pass == null || pass.length() < 4 || pass.length() > 100) {
            error = "새 비밀번호는 4자 이상 입력해 주세요.";
        } else if (!pass.equals(passConfirm)) {
            error = "새 비밀번호가 서로 일치하지 않아요.";
        } else if (MemberDAO.getInstance().resetPassword(resetId, pass)) {
            FindLimiter.clearReset(session);   // 한 번만 사용 가능
            out.println("<script>alert('비밀번호가 변경되었습니다. 새 비밀번호로 로그인해 주세요.'); location.href='loginForm.jsp';</script>");
            return;
        } else {
            error = "비밀번호 변경 중 오류가 발생했어요. 잠시 후 다시 시도해 주세요.";
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>새 비밀번호 설정 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/index.css">
    <link rel="stylesheet" href="../css/member.css">
    <link rel="stylesheet" href="../css/find.css">
</head>
<body>

    <jsp:include page="/module/header.jsp" flush="false"/>

    <section>
        <div id="main_content">
            <div id="join_box">
                <h2>새 비밀번호 설정</h2>

                <form name="reset_form" method="post" action="resetPw.jsp" onsubmit="return checkReset(this);">
                    <p class="find-desc"><b><%= esc(FindLimiter.mask(resetId)) %></b> 계정의 새 비밀번호를 입력해 주세요.<br>
                        10분 안에 변경을 완료해야 해요.</p>

                    <% if (error != null) { %><div class="find-error"><%= esc(error) %></div><% } %>

                    <div class="form-group">
                        <label for="pass">새 비밀번호</label>
                        <input type="password" id="pass" name="pass" maxlength="100" placeholder="4자 이상" autocomplete="new-password">
                    </div>
                    <div class="form-group">
                        <label for="pass_confirm">새 비밀번호 확인</label>
                        <input type="password" id="pass_confirm" name="pass_confirm" maxlength="100" placeholder="새 비밀번호 재입력" autocomplete="new-password">
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn-submit">비밀번호 변경</button>
                        <button type="button" class="btn-reset" onclick="location.href='loginForm.jsp'">취소</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <jsp:include page="/module/footer.jsp" flush="false"/>

<script>
function checkReset(f) {
    if (f.pass.value.length < 4) { alert("새 비밀번호는 4자 이상 입력하세요!"); f.pass.focus(); return false; }
    if (f.pass.value !== f.pass_confirm.value) {
        alert("새 비밀번호가 일치하지 않습니다.\n다시 입력해 주세요!");
        f.pass_confirm.focus(); return false;
    }
    return true;
}
</script>
</body>
</html>