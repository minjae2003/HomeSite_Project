<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.FindLimiter, member.FindMail, java.util.List" %>
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

    String email = request.getParameter("email");
    String error = null;
    boolean sent = false;
    int locked = FindLimiter.lockedMinutes(request);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (locked > 0) {
            error = "요청이 너무 많아요. " + locked + "분 뒤에 다시 시도해 주세요.";
        } else if (!validEmail(email)) {
            error = "이메일 주소를 정확히 입력해 주세요.";
        } else {
            FindLimiter.count(request);
            List<String> ids = MemberDAO.getInstance().findIdsByEmail(email);
            if (!ids.isEmpty() && FindLimiter.takeMail(email)) {
                FindMail.sendIds(email.trim(), ids, FindMail.siteBase(request));
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
    <title>아이디 찾기 - 자취의 품격</title>
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
                    <a href="findId.jsp" class="find-tab active">아이디 찾기</a>
                    <a href="findPw.jsp" class="find-tab">비밀번호 찾기</a>
                </div>

                <% if (sent) { %>
                <div class="find-result">
                    <p class="find-result-title">📧 메일을 확인해 주세요</p>
                    <p class="find-sent"><b><%= esc(email.trim()) %></b> 주소로 가입된 아이디가 있으면<br>아이디 목록을 메일로 보냈어요.</p>
                    <p class="find-note">몇 분 안에 메일이 오지 않으면 <b>스팸함</b>을 확인해 주세요.<br>그래도 없다면 입력한 정보가 가입 정보와 다른 거예요.</p>
                </div>
                <div class="button-group">
                    <button type="button" class="btn-submit" onclick="location.href='loginForm.jsp'">로그인하기</button>
                    <button type="button" class="btn-reset" onclick="location.href='findPw.jsp'">비밀번호 찾기</button>
                </div>
                <% } else { %>
                <form name="find_form" method="post" action="findId.jsp" onsubmit="return checkFind(this);"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                    <p class="find-desc">회원가입 때 입력한 <b>이메일</b>을 입력하면,<br>그 이메일로 가입된 아이디를 <b>메일로</b>보내 드려요.</p>

                    <% if (error != null) { %><div class="find-error"><%= esc(error) %></div><% } %>

                    <div class="form-group">
                        <label for="email">이메일</label>
                        <input type="email" id="email" name="email" maxlength="100" value="<%= esc(email) %>" placeholder="example@email.com" autocomplete="email">
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn-submit">아이디 메일 받기</button>
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
    if (!f.email.value.trim()) { alert("이메일을 입력하세요!"); f.email.focus(); return false; }
    return true;
}
</script>
</body>
</html>
