<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.SiteInfo" %>
<% String policyTab = "privacy"; %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>개인정보처리방침 - 자취의 품격</title>
    <meta name="description" content="자취의 품격 개인정보처리방침입니다.">
    <link rel="stylesheet" href="../css/policy.css">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="policy-wrap">
    <%@ include file="_tabs.jspf" %>
    <article class="policy-card">
        <h1>개인정보처리방침</h1>
        <div class="policy-meta">시행일: <%= SiteInfo.EFFECTIVE_DATE %></div>

        <div class="policy-intro">
            <%= SiteInfo.OPERATOR %>(이하 "운영자")는 「개인정보 보호법」에 따라 회원의 개인정보를 보호하고, 관련 문의를 빠르게 처리하기 위해 다음과 같이 개인정보처리방침을 정하여 공개합니다.
            자취의 품격은 <b>서비스에 꼭 필요한 정보만</b> 모으며, 모은 정보를 다른 곳에 팔거나 넘기지 않습니다.
        </div>

        <ol class="policy-toc">
            <li><a href="#p1">수집하는 개인정보 항목과 수집 방법</a></li>
            <li><a href="#p2">개인정보의 이용 목적</a></li>
            <li><a href="#p3">보유 기간과 파기</a></li>
            <li><a href="#p4">제3자 제공</a></li>
            <li><a href="#p5">처리 위탁</a></li>
            <li><a href="#p6">회원의 권리와 행사 방법</a></li>
            <li><a href="#p7">만 14세 미만 아동의 개인정보</a></li>
            <li><a href="#p8">쿠키 등 자동 수집 장치</a></li>
            <li><a href="#p9">개인정보의 안전성 확보 조치</a></li>
            <li><a href="#p10">개인정보 보호책임자</a></li>
            <li><a href="#p11">권익침해 구제 방법</a></li>
            <li><a href="#p12">개인정보처리방침의 변경</a></li>
        </ol>

        <h2 id="p1">1. 수집하는 개인정보 항목과 수집 방법</h2>
        <table class="policy-table">
            <tr><th>구분</th><th>항목</th><th>수집 시점</th></tr>
            <tr><td>필수</td><td>아이디, 비밀번호, 이름, 닉네임</td><td>회원가입</td></tr>
            <tr><td>선택</td><td>이메일, 전화번호</td><td>회원가입, 회원정보 수정</td></tr>
            <tr><td>선택</td><td>프로필 사진, 한 줄 소개, 지역, 자취 기간, 관심 태그</td><td>프로필 편집</td></tr>
            <tr><td>선택</td><td>문의 종류, 제목, 내용, 관련 글 주소</td><td>문의하기 이용 시</td></tr>
            <tr><td>자동 수집</td><td>접속 IP 주소, 접속 일시, 방문 기록(세션 식별값), 게시글 조회 기록, 로그인 유지용 쿠키</td><td>서비스 이용 중</td></tr>
        </table>
        <ul>
            <li>비밀번호는 복원할 수 없는 방식으로 암호화하여 저장하므로 운영자도 알 수 없습니다.</li>
            <li>회원이 직접 올린 글, 댓글, 사진, 체크리스트 기록은 서비스 이용 과정에서 저장됩니다. <b>글이나 사진에 본인 또는 다른 사람의 개인정보(전화번호, 주소, 얼굴 등)를 올리지 않도록 주의해 주세요.</b></li>
        </ul>

        <h2 id="p2">2. 개인정보의 이용 목적</h2>
        <table class="policy-table">
            <tr><th>항목</th><th>이용 목적</th></tr>
            <tr><td>아이디, 비밀번호</td><td>회원 식별, 로그인</td></tr>
            <tr><td>이름</td><td>아이디 찾기, 비밀번호 재설정 시 본인 확인</td></tr>
            <tr><td>닉네임, 프로필 정보</td><td>게시글·댓글 작성자 표시, 프로필 화면 표시</td></tr>
            <tr><td>이메일</td><td>아이디 찾기, 비밀번호 재설정 시 본인 확인, 문의 답변</td></tr>
            <tr><td>전화번호</td><td>회원 정보 관리, 계정 관련 문제 발생 시 연락</td></tr>
            <tr><td>접속 IP, 접속 일시</td><td>무단 로그인 시도 차단, 부정 이용 방지, 보안 사고 대응</td></tr>
            <tr><td>문의 내용</td><td>문의 확인과 답변, 신고 처리</td></tr>
            <tr><td>방문·조회 기록</td><td>오늘 방문자 수 집계, 실시간 인기글 집계(같은 사람의 중복 조회 제외)</td></tr>
        </table>
        <p>운영자는 위 목적 외의 용도로 개인정보를 이용하지 않으며, 광고나 마케팅에 이용하지 않습니다. 목적이 바뀌면 미리 알리고 동의를 받습니다.</p>

        <h2 id="p3">3. 보유 기간과 파기</h2>
        <table class="policy-table">
            <tr><th>항목</th><th>보유 기간</th></tr>
            <tr><td>회원 정보, 프로필, 작성한 글·댓글·첨부파일, 좋아요, 알림, 체크리스트, 문의 내역</td><td><b>회원 탈퇴 시 즉시 삭제</b></td></tr>
            <tr><td>게시글 조회 기록</td><td>7일 (지나면 자동 삭제)</td></tr>
            <tr><td>방문 기록(세션 식별값, 방문일)</td><td>1년 (지나면 자동 삭제)</td></tr>
            <tr><td>로그인 실패 기록(IP, 아이디)</td><td>서버 메모리에만 최대 약 15분 보관</td></tr>
            <tr><td>서버 접속 기록(IP, 접속 일시, 요청 주소)</td><td>3개월 (「통신비밀보호법」)</td></tr>
        </table>
        <ul>
            <li>파기 방법: 데이터베이스의 정보는 복구할 수 없도록 삭제하고, 업로드된 파일은 서버에서 지웁니다.</li>
            <li>법령에 따라 보관해야 하는 정보가 있으면 그 기간 동안 다른 정보와 분리하여 보관한 뒤 파기합니다.</li>
        </ul>

        <h2 id="p4">4. 제3자 제공</h2>
        <p>운영자는 회원의 개인정보를 제3자에게 제공하지 않습니다. 다만 법령에 근거가 있거나, 수사기관이 법에 정한 절차(영장 등)에 따라 요청하는 경우에는 예외로 합니다.</p>

        <h2 id="p5">5. 처리 위탁</h2>
        <table class="policy-table">
            <tr><th>위탁받는 자</th><th>위탁 업무</th><th>보관 위치</th></tr>
            <tr><td>Amazon Web Services</td><td>서버 및 데이터베이스 운영(클라우드 호스팅)</td><td>대한민국(AWS 서울 리전)</td></tr>
        </table>
        <p>운영자는 위탁받는 자가 개인정보를 안전하게 처리하는지 관리합니다.</p>

        <h2 id="p6">6. 회원의 권리와 행사 방법</h2>
        <ul>
            <li><b>열람·정정</b>: 마이페이지와 회원정보 수정 화면에서 언제든지 확인하고 고칠 수 있습니다.</li>
            <li><b>삭제(탈퇴)</b>: 마이페이지 → 계정 관리에서 직접 탈퇴할 수 있으며, 탈퇴하면 개인정보가 바로 삭제됩니다.</li>
            <li><b>처리 정지·기타 요청</b>: 아래 개인정보 보호책임자 이메일로 요청하시면 지체 없이 처리합니다.</li>
            <li>법정대리인이나 위임을 받은 사람을 통해서도 권리를 행사할 수 있습니다.</li>
        </ul>

        <h2 id="p7">7. 만 14세 미만 아동의 개인정보</h2>
        <p>자취의 품격은 <b>만 14세 미만 아동의 회원가입을 받지 않습니다.</b> 만 14세 미만 아동이 가입한 사실을 알게 되면 해당 계정과 개인정보를 삭제합니다.</p>

        <h2 id="p8">8. 쿠키 등 자동 수집 장치</h2>
        <ul>
            <li>로그인 상태를 유지하기 위해 세션 쿠키(JSESSIONID) 하나만 사용합니다. 브라우저를 닫거나 30분 동안 이용하지 않으면 로그인이 풀립니다.</li>
            <li>자취 체크리스트의 체크 상태를 회원의 브라우저(로컬 저장소)에 저장할 수 있습니다. 이 정보는 회원의 기기에만 남습니다.</li>
            <li>광고, 행동 추적, 외부 분석 도구용 쿠키는 사용하지 않습니다.</li>
            <li>브라우저 설정에서 쿠키를 거부할 수 있지만, 그 경우 로그인이 필요한 기능을 이용할 수 없습니다.</li>
        </ul>

        <h2 id="p9">9. 개인정보의 안전성 확보 조치</h2>
        <ul>
            <li>비밀번호 암호화 저장 (복원할 수 없는 단방향 암호화)</li>
            <li>모든 통신 암호화 (HTTPS)</li>
            <li>로그인·본인 확인 시도 횟수 제한으로 무단 접근 차단</li>
            <li>관리자 기능은 관리자 계정만 사용할 수 있도록 권한 제한</li>
            <li>서버 접근은 인증 키를 가진 운영자만 가능하도록 제한</li>
        </ul>

        <h2 id="p10">10. 개인정보 보호책임자</h2>
        <p>개인정보와 관련한 문의, 불만, 피해 구제 요청은 아래로 연락해 주세요. 빠르게 답변하고 처리하겠습니다.</p>
        <div class="policy-contact">
            개인정보 보호책임자: <%= SiteInfo.OPERATOR %><br>
            이메일: <a href="mailto:<%= SiteInfo.CONTACT_EMAIL %>"><%= SiteInfo.CONTACT_EMAIL %></a>
        </div>

        <h2 id="p11">11. 권익침해 구제 방법</h2>
        <p>개인정보 침해에 대한 상담이나 분쟁 해결이 필요하면 아래 기관에 문의할 수 있습니다.</p>
        <ul>
            <li>개인정보침해 신고센터 (한국인터넷진흥원): 국번 없이 118, privacy.kisa.or.kr</li>
            <li>개인정보 분쟁조정위원회: 1833-6972, www.kopico.go.kr</li>
            <li>대검찰청: 국번 없이 1301, www.spo.go.kr</li>
            <li>경찰청: 국번 없이 182, ecrm.police.go.kr</li>
        </ul>

        <h2 id="p12">12. 개인정보처리방침의 변경</h2>
        <p>이 방침의 내용이 바뀌면 시행 7일 전부터 공지사항으로 알립니다. 수집하는 항목이나 이용 목적이 늘어나는 등 중요한 변경은 30일 전부터 알리고, 필요하면 다시 동의를 받습니다.</p>

        <div class="policy-history">
            <b>변경 이력</b><br>
            · <%= SiteInfo.EFFECTIVE_DATE %>: 개인정보처리방침 제정
        </div>
    </article>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
