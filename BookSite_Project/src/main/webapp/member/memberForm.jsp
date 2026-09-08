<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/index.css">
    <link rel="stylesheet" href="../css/member.css">
    
    <script>
    function check_input() {
        if (!document.member_form.id.value) {
            alert("아이디를 입력하세요!");    
            document.member_form.id.focus();
            return;
        }

        if (!document.member_form.pass.value) {
            alert("비밀번호를 입력하세요!");    
            document.member_form.pass.focus();
            return;
        }

        if (!document.member_form.pass_confirm.value) {
            alert("비밀번호확인을 입력하세요!");    
            document.member_form.pass_confirm.focus();
            return;
        }

        if (!document.member_form.name.value) {
            alert("이름을 입력하세요!");    
            document.member_form.name.focus();
            return;
        }

        if (document.member_form.pass.value != document.member_form.pass_confirm.value) {
            alert("비밀번호가 일치하지 않습니다.\n다시 입력해 주세요!");
            document.member_form.pass.focus();
            document.member_form.pass.select();
            return;
        }

        document.member_form.submit();
    }

    function reset_form() {
        document.member_form.id.value = "";  
        document.member_form.pass.value = "";
        document.member_form.pass_confirm.value = "";
        document.member_form.name.value = "";
        document.member_form.id.focus();
    }
    
    function check_id() {
        if (!document.member_form.id.value) {
            alert("아이디를 입력하세요!");
            document.member_form.id.focus();
            return;
        }
        window.open("memberCheckId.jsp?id=" + document.member_form.id.value,
                    "IDcheck",
                    "left=700,top=300,width=350,height=200,scrollbars=no,resizable=yes");
    }   
    </script>
</head>
<body>

    <jsp:include page="/module/header.jsp" flush="false"/>

    <section>
        <div id="main_content">
            <div id="join_box">
                <form name="member_form" method="post" action="memberPro.jsp">
                    <h2>회원가입</h2>
                    
                    <div class="form-group">
                        <label for="id">아이디</label>
                        <div class="input-with-btn">
                            <input type="text" id="id" name="id" placeholder="아이디 입력">
                            <button type="button" class="btn-check" onclick="check_id()">중복확인</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="pass">비밀번호</label>
                        <input type="password" id="pass" name="pass" placeholder="비밀번호 입력">
                    </div>

                    <div class="form-group">
                        <label for="pass_confirm">비밀번호 확인</label>
                        <input type="password" id="pass_confirm" name="pass_confirm" placeholder="비밀번호 재입력">
                    </div>

                    <div class="form-group">
                        <label for="name">이름</label>
                        <input type="text" id="name" name="name" placeholder="이름 입력">
                    </div>

                    <div class="button-group">
                        <button type="button" class="btn-submit" onclick="check_input()">가입하기</button>
                        <button type="button" class="btn-reset" onclick="reset_form()">초기화</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <jsp:include page="/module/footer.jsp" flush="false"/>

</body>
</html>