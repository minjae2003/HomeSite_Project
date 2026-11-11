<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.SiteInfo" %>
<% String policyTab = "rules"; %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>운영정책 - 자취의 품격</title>
    <meta name="description" content="자취의 품격 커뮤니티 운영정책과 권리침해 신고 방법입니다.">
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
        <h1>운영정책 (커뮤니티 이용 규칙)</h1>
        <div class="policy-meta">시행일: <%= SiteInfo.EFFECTIVE_DATE %></div>

        <div class="policy-intro">
            자취의 품격은 자취생들이 서로 돕고 경험을 나누는 공간입니다. 모두가 편하게 이용할 수 있도록 아래 규칙을 지켜 주세요.
            이 정책은 <a href="terms.jsp">이용약관</a>의 회원 의무와 게시물 관리 기준을 쉽게 풀어 쓴 것입니다.
        </div>

        <ol class="policy-toc">
            <li><a href="#r1">기본 원칙</a></li>
            <li><a href="#r2">올리면 안 되는 게시물</a></li>
            <li><a href="#r3">게시판별 이용 안내</a></li>
            <li><a href="#r4">위반 시 조치</a></li>
            <li><a href="#report">권리침해 신고 (게시중단 요청)</a></li>
            <li><a href="#r6">이의 제기</a></li>
        </ol>

        <h2 id="r1">1. 기본 원칙</h2>
        <ul>
            <li>서로 존중하는 말투로 이야기해 주세요. 의견이 달라도 사람을 공격하지 않습니다.</li>
            <li>내 경험과 정보를 나눌 때는 사실에 근거해 주세요. 확실하지 않은 정보는 "제 경우에는"처럼 밝혀 주세요.</li>
            <li>질문에 답해 준 분께 댓글이나 ❤️ 좋아요로 고마움을 표현해 주세요.</li>
        </ul>

        <h2 id="r2">2. 올리면 안 되는 게시물</h2>
        <table class="policy-table">
            <tr><th>구분</th><th>예시</th></tr>
            <tr><td>욕설·비방·혐오</td><td>욕설, 인신공격, 성별·지역·나이·장애·출신 등에 대한 차별·혐오 표현, 특정인 저격 글</td></tr>
            <tr><td>개인정보 노출</td><td>본인이나 다른 사람의 전화번호, 주소, 계좌번호, 차량번호, 얼굴이 드러난 사진을 동의 없이 올리는 것. 집주인·이웃 등의 신상 공개</td></tr>
            <tr><td>명예훼손·사생활 침해</td><td>사실 여부와 관계없이 특정인을 알아볼 수 있게 비방하거나 사생활을 폭로하는 글</td></tr>
            <tr><td>음란·폭력</td><td>음란물, 성적 수치심을 주는 표현, 잔인하거나 폭력적인 사진·영상</td></tr>
            <tr><td>광고·도배</td><td>상업 광고, 홍보 링크, 같은 글 반복 게시, 의미 없는 글·댓글 연속 작성</td></tr>
            <tr><td>불법 정보</td><td>불법 도박·대출·의약품 안내, 불법 촬영물, 범죄를 권하거나 돕는 내용</td></tr>
            <tr><td>권리 침해</td><td>다른 사람의 글·사진·영상을 출처 없이 가져오는 것, 저작권이 있는 콘텐츠 무단 게시</td></tr>
            <tr><td>사칭·사기</td><td>운영자나 다른 회원을 사칭하는 것, 거래를 빙자한 사기, 거짓 정보로 다른 사람을 속이는 것</td></tr>
        </table>

        <h2 id="r3">3. 게시판별 이용 안내</h2>
        <ul>
            <li><b>💡 자취꿀팁</b>: 직접 해 보고 효과를 본 생활 팁을 올려 주세요.</li>
            <li><b>❓ 질문/답변</b>: 궁금한 점을 자유롭게 물어보세요. 해결되면 어떻게 해결했는지 댓글로 남겨 주면 다음 사람에게 도움이 됩니다.</li>
            <li><b>🏫 일상/수다</b>: 자취 생활 이야기라면 무엇이든 좋아요.</li>
            <li><b>🍳 요리레시피</b>: 자취방에서 만들 수 있는 요리를 사진과 함께 올려 주세요.</li>
            <li>글의 주제와 맞지 않는 게시판에 올린 글은 운영자가 다른 게시판으로 옮기거나 수정을 요청할 수 있습니다.</li>
            <li>공지사항과 📌 고정글은 운영자만 작성·지정할 수 있습니다.</li>
        </ul>

        <p>욕설·비방·도박 광고 등 <b>금칙어가 들어간 글, 댓글, 닉네임은 자동으로 등록되지 않아요.</b> 띄어쓰기나 숫자·기호를 끼워 넣어 피해 가는 표현도 걸러집니다.</p>

        <h2 id="r4">4. 위반 시 조치</h2>
        <p>위반 정도와 횟수에 따라 아래 순서로 조치합니다. 불법 정보나 심각한 위반은 단계와 관계없이 바로 삭제하고 이용을 제한할 수 있습니다.</p>
        <table class="policy-table">
            <tr><th>단계</th><th>조치</th></tr>
            <tr><td>1차</td><td>게시물 숨김 또는 삭제 + 경고 알림</td></tr>
            <tr><td>2차</td><td>게시물 삭제 + 7일 이용 정지</td></tr>
            <tr><td>3차</td><td>게시물 삭제 + 30일 이용 정지</td></tr>
            <tr><td>4차 이상 / 중대한 위반</td><td>회원 자격 박탈(강제 탈퇴) 및 재가입 제한</td></tr>
        </table>
        <p>조치를 하면 해당 회원에게 사유를 알려 드립니다.</p>

        <h2 id="report">5. 권리침해 신고 (게시중단 요청)</h2>
        <p>자취의 품격의 게시물 때문에 명예훼손, 사생활 침해, 저작권 침해 등 권리를 침해받았다면 아래 방법으로 신고해 주세요. <b>회원이 아니어도 신고할 수 있습니다.</b></p>

        <h3>회원이라면: 사이트에서 바로 신고</h3>
        <p>게시글 아래의 <b>🚨 신고</b> 버튼을 누르거나 <a href="../support/inquiry.jsp?category=REPORT">문의하기</a>에서 종류를 <b>게시물·회원 신고</b>로 골라 보내 주세요. 운영자만 볼 수 있고, 처리 결과는 알림으로 알려 드립니다.</p>

        <h3>회원이 아니라면: 이메일로 신고</h3>
        <div class="policy-contact">
            신고 이메일: <a href="mailto:<%= SiteInfo.CONTACT_EMAIL %>"><%= SiteInfo.CONTACT_EMAIL %></a><br>
            제목에 <b>[권리침해 신고]</b>를 붙여 주시면 더 빨리 확인할 수 있습니다.
        </div>
        <p>어느 방법이든 아래 내용을 함께 보내 주세요.</p>
        <ol>
            <li>신고하는 분의 이름과 연락처(이메일)</li>
            <li>문제가 되는 게시물의 주소(URL)</li>
            <li>어떤 권리가 어떻게 침해되었는지에 대한 설명</li>
            <li>본인이 침해당한 당사자임을 알 수 있는 자료 (대리인은 위임장)</li>
            <li>저작권 침해의 경우, 본인이 권리자임을 알 수 있는 자료(원본 파일, 게시 기록 등)</li>
        </ol>

        <h3>처리 절차</h3>
        <ol>
            <li><b>접수 확인</b>: 신고를 받으면 내용을 확인합니다.</li>
            <li><b>조치</b>: 명백한 위반이면 바로 삭제합니다. 침해 여부를 판단하기 어렵거나 당사자 사이에 다툼이 예상되면, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」 제44조의2에 따라 <b>최대 30일 동안 게시물을 숨기는 임시조치</b>를 합니다.</li>
            <li><b>통지</b>: 신고한 분과 게시물 작성자에게 조치 내용을 알립니다.</li>
            <li><b>재게시 요청</b>: 게시물 작성자는 임시조치 기간 안에 재게시를 요청할 수 있으며, 운영자는 양쪽 의견을 확인한 뒤 복원하거나 삭제합니다.</li>
            <li><b>기간 종료</b>: 임시조치 기간 안에 재게시 요청이 없으면 게시물을 삭제할 수 있습니다.</li>
        </ol>
        <p>거짓 신고로 다른 사람의 게시물을 내리게 하면 법적 책임을 질 수 있습니다.</p>

        <h2 id="r6">6. 이의 제기</h2>
        <p>내 게시물이 숨겨지거나 삭제되었거나 이용 제한을 받았는데 동의하기 어렵다면, 조치 알림을 받은 날부터 30일 안에 <a href="../support/inquiry.jsp">문의하기</a> 또는 위 이메일로 이의를 제기해 주세요. 다시 검토한 뒤 결과를 알려 드립니다.</p>

        <div class="policy-history">
            <b>변경 이력</b><br>
            · <%= SiteInfo.EFFECTIVE_DATE %>: 운영정책 제정
        </div>
    </article>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
