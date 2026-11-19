<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.FindLimiter, member.FindMail, member.PasswordResetDAO" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private static boolean validEmail(String e) {
        return e != null && e.length() <= 100 && e.trim().matches("[^\\s@<>\",;]+@[^\\s@<>\",;]+\\.[^\\s@<>\",;]+");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String email = request.getParameter("email");
    String error = null;
    boolean sent = false;
    int locked = FindLimiter.lockedMinutes(request);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (locked > 0) {
            error = "요청이 너무 많아요. " + locked + "분 뒤에 다시 시도해 주세요.";
        } else if (id == null || id.trim().isEmpty() || id.length() > 50) {
            error = "아이디를 입력해 주세요.";
        } else if (!validEmail(email)) {
            error = "이메일 주소를 정확히 입력해 주세요.";
        } else {
            FindLimiter.count(request);
            String to = MemberDAO.getInstance().emailForReset(id, email);
            if (to != null && FindLimiter.takeMail(to)) {
                String token = PasswordResetDAO.getInstance().create(id.trim());
                if (token != null) {
                    FindMail.sendReset(to, id.trim(), FindMail.siteBase(request) + "/member/resetPw.jsp?token=" + token);
                }
            }
            // 가입 여부를 알 수 없게, 결과와 상관없이 같은 안내를 보여줌
            sent = true;
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>비밀번호 찾기 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/index.css">
    <link rel="stylesheet" href="../css/member.css">
    <link rel="stylesheet" href="../css/find.css">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
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

                <% if (sent) { %>
                <div class="find-result">
                    <p class="find-result-title">📧 메일을 확인해 주세요</p>
                    <p class="find-sent"><b><%= esc(email.trim()) %></b><br>아이디와 이메일이 가입 정보와 맞으면 이 주소로<br>비밀번호 재설정 링크를 보냈어요. (30분 동안 한 번만 사용 가능)</p>
                    <p class="find-note">몇 분 안에 메일이 오지 않으면 <b>스팸함</b>을 확인해 주세요.<br>그래도 없다면 입력한 정보가 가입 정보와 다른 거예요.</p>
                </div>
                <div class="button-group">
                    <button type="button" class="btn-submit" onclick="location.href='loginForm.jsp'">로그인하기</button>
                </div>
                <% } else { %>
                <form name="find_form" method="post" action="findPw.jsp" onsubmit="return checkFind(this);"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                    <p class="find-desc"><b>아이디</b>와 가입할 때 쓴 <b>이메일</b>을 입력하면,<br>새 비밀번호를 설정할 수 있는 <b>링크를 메일로</b>보내 드려요.</p>

                    <% if (error != null) { %><div class="find-error"><%= esc(error) %></div><% } %>

                    <div class="form-group">
                        <label for="id">아이디</label>
                        <input type="text" id="id" name="id" maxlength="50" value="<%= esc(id) %>" placeholder="아이디 입력" autocomplete="username">
                    </div>
                    <div class="form-group">
                        <label for="email">이메일</label>
                        <input type="email" id="email" name="email" maxlength="100" value="<%= esc(email) %>" placeholder="example@email.com" autocomplete="email">
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn-submit">재설정 메일 받기</button>
                    </div>
                    <p class="find-note">이메일을 등록하지 않은 계정은 찾을 수 없어요. <a href="../support/inquiry.jsp">문의하기</a>로 알려 주세요.</p>
                </form>
                <% } %>

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
    if (!f.email.value.trim()) { alert("이메일을 입력하세요!"); f.email.focus(); return false; }
    return true;
}
</script>
</body>
</html>
