<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/member.css">
    
   <script>
    function check_input() {
        var f = document.member_form;

        if (!f.id.value) { alert("아이디를 입력하세요!"); f.id.focus(); return; }
        if (!f.pass.value) { alert("비밀번호를 입력하세요!"); f.pass.focus(); return; }
        if (!f.pass_confirm.value) { alert("비밀번호확인을 입력하세요!"); f.pass_confirm.focus(); return; }
        if (!f.name.value) { alert("이름을 입력하세요!"); f.name.focus(); return; }

        var nickname = f.nickname.value.trim();
        if (nickname.length < 2) { alert("닉네임을 2자 이상 입력하세요!"); f.nickname.focus(); return; }

        if (f.pass.value != f.pass_confirm.value) {
            alert("비밀번호가 일치하지 않습니다.\n다시 입력해 주세요!");
            f.pass.focus(); f.pass.select();
            return;
        }

        // 이메일은 선택 사항: 입력한 경우에만 형식 검사
        var email = f.email.value.trim();
        if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            alert("이메일 형식이 올바르지 않습니다.\n예) example@email.com");
            f.email.focus();
            return;
        }

        // 전화번호는 선택 사항: 입력한 경우에만 형식 검사
        var phone = f.phone.value.replace(/[^0-9]/g, "");
        if (phone) {
            var ok = phone.indexOf("02") === 0 ? (phone.length === 9 || phone.length === 10)
                                               : (/^0\d+$/.test(phone) && (phone.length === 10 || phone.length === 11));
            if (!ok) {
                alert("전화번호 형식이 올바르지 않습니다.\n예) 010-1234-5678");
                f.phone.focus();
                return;
            }
        }

        f.submit();
    }

    function reset_form() {
        var f = document.member_form;
        f.id.value = "";
        f.pass.value = "";
        f.pass_confirm.value = "";
        f.name.value = "";
        f.nickname.value = "";
        f.email.value = "";
        f.phone.value = "";
        f.id.focus();
    }

    function check_id() {
        if (!document.member_form.id.value) {
            alert("아이디를 입력하세요!");
            document.member_form.id.focus();
            return;
        }
        window.open("memberCheckId.jsp?id=" + encodeURIComponent(document.member_form.id.value),
                    "IDcheck",
                    "left=700,top=300,width=350,height=200,scrollbars=no,resizable=yes");
    }

    // 전화번호 입력 시 하이픈 자동 입력 (02 지역번호도 처리)
    function formatPhone(input) {
        var d = input.value.replace(/[^0-9]/g, "").substring(0, 11);
        var out;
        if (d.indexOf("02") === 0) {
            if (d.length <= 2) out = d;
            else if (d.length <= 5) out = d.substring(0, 2) + "-" + d.substring(2);
            else if (d.length <= 9) out = d.substring(0, 2) + "-" + d.substring(2, 5) + "-" + d.substring(5);
            else out = d.substring(0, 2) + "-" + d.substring(2, 6) + "-" + d.substring(6, 10);
        } else {
            if (d.length <= 3) out = d;
            else if (d.length <= 6) out = d.substring(0, 3) + "-" + d.substring(3);
            else if (d.length <= 10) out = d.substring(0, 3) + "-" + d.substring(3, 6) + "-" + d.substring(6);
            else out = d.substring(0, 3) + "-" + d.substring(3, 7) + "-" + d.substring(7);
        }
        input.value = out;
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
                    
                    <div class="form-group">
                        <label for="nickname">닉네임</label>
                        <input type="text" id="nickname" name="nickname" maxlength="50" placeholder="게시판에 표시될 이름 (2자 이상)">
                    </div>
                    
                     <div class="form-group">
                        <label for="email">이메일 <span class="label-optional">(선택)</span></label>
                        <input type="email" id="email" name="email" maxlength="100" placeholder="example@email.com">
                    </div>
                    
                                       <div class="form-group">
                        <label for="phone">전화번호 <span class="label-optional">(선택)</span></label>
                        <input type="tel" id="phone" name="phone" maxlength="13" placeholder="010-1234-5678" oninput="formatPhone(this)">
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