<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
    <script>
        function validateForm() {
            var form = document.joinFrm;
            
            if (!form.id.value.trim()) {
                alert("아이디를 입력하세요.");
                form.id.focus();
                return false;
            }
            if (!form.password.value.trim()) {
                alert("비밀번호를 입력하세요.");
                form.password.focus();
                return false;
            }
            if (form.password.value !== form.passwordConfirm.value) {
                alert("비밀번호가 일치하지 않습니다.");
                form.passwordConfirm.focus();
                return false;
            }
            if (!form.name.value.trim()) {
                alert("이름을 입력하세요.");
                form.name.focus();
                return false;
            }
            if (!form.nickname.value.trim()) {
                alert("닉네임을 입력하세요.");
                form.nickname.focus();
                return false;
            }
            if (!form.email.value.trim()) {
                alert("이메일을 입력하세요.");
                form.email.focus();
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <jsp:include page="/module/header.jsp" flush="false"/>

    <div class="container" style="max-width: 500px; margin: 50px auto;">
        <h2>회원가입</h2>
        <form name="joinFrm" action="joinPro.jsp" method="post" onsubmit="return validateForm();">
            <div style="margin-bottom: 15px;">
                <label>아이디</label><br>
                <input type="text" name="id" style="width: 100%; padding: 8px;" required>
            </div>
            <div style="margin-bottom: 15px;">
                <label>비밀번호</label><br>
                <input type="password" name="password" style="width: 100%; padding: 8px;" required>
            </div>
            <div style="margin-bottom: 15px;">
                <label>비밀번호 확인</label><br>
                <input type="password" name="passwordConfirm" style="width: 100%; padding: 8px;" required>
            </div>
            <div style="margin-bottom: 15px;">
                <label>이름</label><br>
                <input type="text" name="name" style="width: 100%; padding: 8px;" required>
            </div>
            <div style="margin-bottom: 15px;">
                <label>닉네임</label><br>
                <input type="text" name="nickname" style="width: 100%; padding: 8px;" required>
            </div>
            <div style="margin-bottom: 15px;">
                <label>이메일</label><br>
                <input type="email" name="email" style="width: 100%; padding: 8px;" required>
            </div>
            <button type="submit" style="width: 100%; padding: 10px; background-color: #4CAF50; color: white; border: none;">가입하기</button>
        </form>
    </div>

    <jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>