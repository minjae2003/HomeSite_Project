<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginForm.jsp';</script>");
        return;
    }
    MemberVO member = MemberDAO.getInstance().getMember(sessionUserId);
    if (member == null) {
        out.println("<script>alert('회원 정보를 찾을 수 없습니다.'); location.href='../main/index.jsp';</script>");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>회원정보 수정 — 자취의 품격</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/index.css">
<script>
    function checkForm(f) {
        if (!f.nickname.value.trim()) { alert('닉네임을 입력하세요.'); f.nickname.focus(); return false; }
        if (!f.name.value.trim()) { alert('이름을 입력하세요.'); f.name.focus(); return false; }
        if (!f.email.value.trim()) { alert('이메일을 입력하세요.'); f.email.focus(); return false; }
        if (f.newPass.value !== f.newPassConfirm.value) {
            alert('새 비밀번호가 서로 일치하지 않습니다.'); f.newPassConfirm.focus(); return false;
        }
        if (!f.currentPass.value) { alert('변경하려면 현재 비밀번호를 입력하세요.'); f.currentPass.focus(); return false; }
        return true;
    }
</script>
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="wrap">
  <div class="form-card">
    <h1 class="page-title">⚙️ 회원정보 수정</h1>
    <p class="page-sub" style="margin-bottom:22px;">닉네임·이름·이메일과 비밀번호를 변경할 수 있어요.</p>

    <form method="post" action="memberUpdatePro.jsp" onsubmit="return checkForm(this);">
      <div class="form-group">
        <label class="form-label">아이디</label>
        <input type="text" class="input-control" value="<%= esc(member.getId()) %>" readonly>
      </div>
      <div class="form-group">
        <label class="form-label" for="nickname">닉네임</label>
        <input type="text" id="nickname" name="nickname" class="input-control" maxlength="50" value="<%= esc(member.getNickname()) %>">
        <div class="form-hint">이미 작성한 글·댓글의 작성자 이름은 작성 당시 닉네임으로 유지돼요.</div>
      </div>
      <div class="form-group">
        <label class="form-label" for="name">이름</label>
        <input type="text" id="name" name="name" class="input-control" maxlength="50" value="<%= esc(member.getName()) %>">
      </div>
      <div class="form-group">
        <label class="form-label" for="email">이메일</label>
        <input type="email" id="email" name="email" class="input-control" maxlength="100" value="<%= esc(member.getEmail()) %>">
      </div>

      <hr class="form-divider" id="password">

      <div class="form-group">
        <label class="form-label" for="newPass">새 비밀번호</label>
        <input type="password" id="newPass" name="newPass" class="input-control" maxlength="100" autocomplete="new-password">
        <div class="form-hint">바꾸지 않으려면 비워두세요.</div>
      </div>
      <div class="form-group">
        <label class="form-label" for="newPassConfirm">새 비밀번호 확인</label>
        <input type="password" id="newPassConfirm" name="newPassConfirm" class="input-control" maxlength="100" autocomplete="new-password">
      </div>

      <hr class="form-divider">

      <div class="form-group">
        <label class="form-label" for="currentPass">현재 비밀번호 <span style="color:#D9534F;">*</span></label>
        <input type="password" id="currentPass" name="currentPass" class="input-control" maxlength="100" autocomplete="current-password">
        <div class="form-hint">본인 확인을 위해 현재 비밀번호를 입력해야 저장돼요.</div>
      </div>

      <div class="form-actions">
        <a href="../mypage/account.jsp" class="btn btn-outline">취소</a>
        <button type="submit" class="btn btn-primary">저장하기</button>
      </div>
    </form>
  </div>
</div>

</body>
</html>
