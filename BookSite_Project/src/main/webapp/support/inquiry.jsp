<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil, util.SiteInfo, inquiry.InquiryDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String inqUserId = (String) session.getAttribute("id");

    String preCategory = request.getParameter("category");
    if (!InquiryDAO.isValidCategory(preCategory)) preCategory = "USE";
    String preUrl = request.getParameter("url");
    if (preUrl == null || preUrl.length() > 300 || !preUrl.matches("^(https?://|/)\\S*$")) preUrl = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>문의하기 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/support.css">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="sp-wrap">
    <div class="sp-head">
        <div>
            <h1>📮 문의하기</h1>
            <p>궁금한 점, 오류, 신고할 내용을 남겨 주시면 운영자가 확인하고 답변해 드려요.</p>
        </div>
        <% if (inqUserId != null) { %><a class="sp-link" href="myInquiries.jsp">내 문의 내역 ›</a><% } %>
    </div>

    <div class="sp-card">
    <% if (inqUserId == null) { %>
        <div class="sp-login">
            <p>문의는 로그인한 회원만 남길 수 있어요.<br>답변이 등록되면 알림으로 알려 드립니다.</p>
            <a class="sp-btn primary" href="../member/loginForm.jsp">로그인하기</a>
            <a class="sp-btn gray" href="../member/memberForm.jsp">회원가입</a>
        </div>
        <div class="sp-note" style="margin:24px 0 0;">
            회원이 아니거나, 게시물로 명예훼손·사생활 침해·저작권 침해를 당해 <b>권리침해 신고</b>를 하려면
            이메일(<%= SiteInfo.CONTACT_EMAIL %>)로 보내 주세요. 자세한 방법은 <a href="../policy/rules.jsp#report">권리침해 신고 안내</a>를 확인해 주세요.
        </div>
    <% } else { %>
        <div class="sp-note">
            문의 내용은 <b>운영자만</b> 볼 수 있어요. 답변이 등록되면 🔔 알림으로 알려 드려요.<br>
            게시물이나 회원을 신고할 때는 <b>관련 글 주소</b>를 함께 적어 주시면 빠르게 확인할 수 있어요.
        </div>

        <form method="post" action="inquiryPro.jsp" onsubmit="return checkInquiry(this);">
            <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">

            <div class="sp-field">
                <label for="category">문의 종류</label>
                <select id="category" name="category">
                <% for (String[] c : InquiryDAO.CATEGORIES) { %>
                    <option value="<%= c[0] %>" <%= c[0].equals(preCategory) ? "selected" : "" %>><%= c[1] %></option>
                <% } %>
                </select>
            </div>

            <div class="sp-field">
                <label for="subject">제목</label>
                <input type="text" id="subject" name="subject" maxlength="100" placeholder="문의 제목을 입력해 주세요">
            </div>

            <div class="sp-field">
                <label for="content">내용</label>
                <textarea id="content" name="content" maxlength="2000" placeholder="문의 내용을 자세히 적어 주세요.&#10;오류라면 어떤 화면에서 무엇을 했을 때 생겼는지 알려 주시면 큰 도움이 돼요."></textarea>
                <div class="sp-count"><span id="contentCount">0</span> / 2000</div>
            </div>

            <div class="sp-field">
                <label for="page_url">관련 글 주소 <small>(선택)</small></label>
                <input type="text" id="page_url" name="page_url" maxlength="300" placeholder="https://jachiclass.com/freeboard/content.jsp?num=..." value="<%= HtmlUtil.esc(preUrl) %>">
            </div>

            <div class="sp-actions">
                <button type="button" class="sp-btn gray" onclick="history.back()">취소</button>
                <button type="submit" class="sp-btn primary">문의 보내기</button>
            </div>
        </form>
    <% } %>
    </div>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
<script>
(function () {
    var ta = document.getElementById('content'), cnt = document.getElementById('contentCount');
    if (ta && cnt) ta.addEventListener('input', function () { cnt.textContent = ta.value.length; });
})();
function checkInquiry(f) {
    if (f.subject.value.trim().length < 2) { alert('제목을 2자 이상 입력해 주세요.'); f.subject.focus(); return false; }
    if (f.content.value.trim().length < 5) { alert('내용을 5자 이상 입력해 주세요.'); f.content.focus(); return false; }
    var url = f.page_url.value.trim();
    if (url && !/^(https?:\/\/|\/)\S*$/.test(url)) { alert('관련 글 주소는 http:// 또는 https:// 로 시작하는 주소로 입력해 주세요.'); f.page_url.focus(); return false; }
    var btn = f.querySelector('button[type=submit]');
    btn.disabled = true; btn.textContent = '보내는 중...';
    return true;
}
</script>
</body>
</html>
