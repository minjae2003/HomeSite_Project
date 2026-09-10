<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <style>
        .join-box { width: 400px; margin: 50px auto; font-family: sans-serif; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input { width: 100%; padding: 8px; box-sizing: border-box; }
        .btn-submit { width: 100%; padding: 10px; background-color: #28a745; color: white; border: none; cursor: pointer; }
        .btn-check { padding: 8px 12px; background-color: #007bff; color: white; border: none; cursor: pointer; }
    </style>
    <script>
        function validateForm() {
            var form = document.joinFrm;
            
            if (!form.id.value.trim()) {
                alert("아이디를 입력하세요.");
                form.id.focus();
                return false;
            }
            if (!form.pass.value.trim()) {
                alert("비밀번호를 입력하세요.");
                form.pass.focus();
                return false;
            }
            if (form.pass.value !== form.passConfirm.value) {
                alert("비밀번호가 일치하지 않습니다.");
                form.passConfirm.focus();
                return false;
            }
            if (!form.name.value.trim()) {
                alert("이름을 입력하세요.");
                form.name.focus();
                return false;
            }
            return true;
        }

        // 아이디 중복확인 팝업
        function openIdCheck() {
            var id = document.joinFrm.id.value;
            if (!id.trim()) {
                alert("아이디를 입력해 주세요.");
                document.joinFrm.id.focus();
                return;
            }
            window.open("memberCheckId.jsp?id=" + encodeURIComponent(id), "idCheck", "width=400,height=250");
        }
    </script>
</head>
<body>
    <div class="join-box">
        <h2>회원가입</h2>
        <form name="joinFrm" action="memberPro.jsp" method="post" onsubmit="return validateForm();">
            <div class="form-group">
                <label>아이디</label>
                <div style="display: flex; gap: 5px;">
                    <input type="text" name="id" placeholder="아이디 입력">
                    <button type="button" class="btn-check" onclick="openIdCheck()">중복확인</button>
                </div>
            </div>
            
            <div class="form-group">
                <label>비밀번호</label>
                <input type="password" name="pass" placeholder="비밀번호 입력">
            </div>

            <div class="form-group">
                <label>비밀번호 확인</label>
                <input type="password" name="passConfirm" placeholder="비밀번호 재입력">
            </div>

            <div class="form-group">
                <label>이름</label>
                <input type="text" name="name" placeholder="이름 입력">
            </div>

            <div class="form-group">
                <label>닉네임</label>
                <input type="text" name="nickname" placeholder="닉네임 입력">
            </div>

            <div class="form-group">
                <label>이메일</label>
                <input type="email" name="email" placeholder="example@email.com">
            </div>

            <button type="submit" class="btn-submit">가입하기</button>
        </form>
    </div>
</body>
</html>