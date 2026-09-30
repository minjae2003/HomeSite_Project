<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.FindLimiter, java.util.List" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String name = request.getParameter("name");
    String email = request.getParameter("email");
    boolean submitted = "POST".equalsIgnoreCase(request.getMethod());

    String error = null;
    List<String> found = null;
    int locked = FindLimiter.lockedMinutes(session);

    if (submitted) {
        if (locked > 0) {
            error = "확인에 여러 번 실패해서 " + locked + "분 뒤에 다시 시도할 수 있어요.";
        } else if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            error = "이름과 이메일을 모두 입력해 주세요.";
        } else {
            found = MemberDAO.getInstance().findIds(name, email);
            if (found.isEmpty()) {
                int left = FindLimiter.fail(session);
                error = left > 0
                    ? "일치하는 회원 정보가 없어요. (남은 시도 " + left + "회)"
                    : "확인에 여러 번 실패해서 10분 동안 찾기를 이용할 수 없어요.";
                found = null;
            } else {
                FindLimiter.success(session);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아이디 찾기 - 자취의 품격</title>
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
                    <a href="findId.jsp" class="find-tab active">아이디 찾기</a>
                    <a href="findPw.jsp" class="find-tab">비밀번호 찾기</a>
                </div>

                <% if (found != null) { %>
                <!-- 찾기 결과 -->
                <div class="find-result">
                    <p class="find-result-title">입력하신 정보와 일치하는 아이디예요.</p>
                    <ul class="find-id-list">
                        <% for (String id : found) { %>
                        <li><%= esc(FindLimiter.mask(id)) %></li>
                        <% } %>
                    </ul>
                    <p class="find-note">개인정보 보호를 위해 아이디 일부는 * 로 가려서 보여드려요.</p>
                </div>
                <div class="button-group">
                    <button type="button" class="btn-submit" onclick="location.href='loginForm.jsp'">로그인하기</button>
                    <button type="button" class="btn-reset" onclick="location.href='findPw.jsp'">비밀번호 찾기</button>
                </div>
                <% } else { %>
                <form name="find_form" method="post" action="findId.jsp" onsubmit="return checkFind(this);">
                    <p class="find-desc">회원가입 때 입력한 <b>이름</b>과 <b>이메일</b>을 입력해 주세요.</p>

                    <% if (error != null) { %><div class="find-error"><%= esc(error) %></div><% } %>

                    <div class="form-group">
                        <label for="name">이름</label>
                        <input type="text" id="name" name="name" maxlength="50" value="<%= esc(name) %>" placeholder="이름 입력">
                    </div>
                    <div class="form-group">
                        <label for="email">이메일</label>
                        <input type="email" id="email" name="email" maxlength="100" value="<%= esc(email) %>" placeholder="example@email.com">
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn-submit">아이디 찾기</button>
                    </div>
                    <p class="find-note">이메일을 등록하지 않은 계정은 찾을 수 없어요. 관리자에게 문의해 주세요.</p>
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
    if (!f.name.value.trim()) { alert("이름을 입력하세요!"); f.name.focus(); return false; }
    if (!f.email.value.trim()) { alert("이메일을 입력하세요!"); f.email.focus(); return false; }
    return true;
}
</script>
</body>
</html>