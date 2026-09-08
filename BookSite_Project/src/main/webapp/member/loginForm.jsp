<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/index.css">
    <link rel="stylesheet" href="../css/login.css">
    
    <script>
    function check_input() {
        if (!document.login_form.id.value) {
            alert("아이디를 입력하세요");    
            document.login_form.id.focus();
            return;
        }

        if (!document.login_form.passwd.value) {
            alert("비밀번호를 입력하세요");    
            document.login_form.passwd.focus();
            return;
        }
        
        document.login_form.submit();
    }
    </script>
</head>
<body>

    <jsp:include page="/module/header.jsp" flush="false"/>

    <section>
        <div id="main_content">
            <div id="login_box">
                <form name="login_form" method="post" action="loginPro.jsp">    
                    <h2>로그인</h2>    
                    <div class="form">
                        <input type="text" name="id" placeholder="아이디">
                    </div>
                    <div class="form">
                        <input type="password" id="passwd" name="passwd" placeholder="비밀번호" onkeyup="if(window.event.keyCode==13){check_input();}">
                    </div>
                    <div id="login_btn">
                        <button type="button" onclick="check_input()">Log in</button>
                    </div>            
                </form>
            </div>
        </div>
    </section>

    <jsp:include page="/module/footer.jsp" flush="false"/>

</body>
</html>