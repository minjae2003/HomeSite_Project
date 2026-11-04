<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%
    // 평문 비밀번호 → 해시 일괄 변환 (배포 직후 관리자가 1번만 실행하고, 이 파일은 삭제할 것)
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);   // 관리자 외에는 페이지 존재 자체를 숨김
        return;
    }
    String result = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int n = MemberDAO.getInstance().migratePlainPasswords();
        result = n + "개 계정의 비밀번호를 해시로 변환했습니다.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1"><title>비밀번호 해시 변환</title></head>
<body style="font-family:sans-serif; margin:40px;">
    <h2>비밀번호 해시 일괄 변환</h2>
    <p>아직 평문으로 저장된 회원 비밀번호를 모두 해시로 바꿉니다. 이미 변환된 계정은 건드리지 않으며, 여러 번 실행해도 안전합니다.</p>
    <% if (result != null) { %><p style="color:#2e7d32;"><b><%= result %></b><br>작업이 끝났으면 서버에서 admin/migratePw.jsp 파일을 삭제하세요.</p><% } %>
    <form method="post" onsubmit="return confirm('변환을 실행할까요?');"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
        <button type="submit">변환 실행</button>
    </form>
</body>
</html>
