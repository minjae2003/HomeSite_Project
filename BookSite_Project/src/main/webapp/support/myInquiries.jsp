<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil, inquiry.InquiryDAO, inquiry.InquiryVO, java.util.List" %>
<%
    String inqUserId = (String) session.getAttribute("id");
    if (inqUserId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
    List<InquiryVO> myList = InquiryDAO.getInstance().listByUser(inqUserId, 100);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>내 문의 내역 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/support.css">
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="sp-wrap">
    <div class="sp-head">
        <div>
            <h1>📮 내 문의 내역</h1>
            <p>보낸 문의와 운영자 답변을 확인할 수 있어요. 제목을 누르면 내용이 펼쳐져요.</p>
        </div>
        <a class="sp-btn primary small" href="inquiry.jsp">+ 새 문의</a>
    </div>

    <% if (myList.isEmpty()) { %>
        <div class="sp-card sp-empty">아직 보낸 문의가 없어요.</div>
    <% } %>
    <% for (InquiryVO q : myList) { %>
        <details class="sp-item <%= q.isDone() ? "" : "wait" %>" <%= myList.size() == 1 ? "open" : "" %>>
            <summary>
                <span class="sp-badge <%= q.isDone() ? "done" : "wait" %>"><%= q.isDone() ? "답변 완료" : "답변 대기" %></span>
                <span class="sp-badge cat"><%= HtmlUtil.esc(q.getCategoryName()) %></span>
                <span class="sp-subject"><%= HtmlUtil.esc(q.getSubject()) %></span>
                <span class="sp-meta"><%= q.getRegDateText() %></span>
            </summary>
            <div class="sp-body">
                <p class="sp-text"><%= HtmlUtil.esc(q.getContent()) %></p>
                <% if (q.getPageUrl() != null) { %>
                    <div class="sp-url">관련 주소: <%= HtmlUtil.esc(q.getPageUrl()) %></div>
                <% } %>
                <% if (q.isDone()) { %>
                    <div class="sp-answer">
                        <h4>✉️ 운영자 답변 · <%= q.getAnsweredAtText() %></h4>
                        <p class="sp-text"><%= HtmlUtil.esc(q.getAnswer()) %></p>
                    </div>
                <% } else { %>
                    <form class="sp-row-actions" method="post" action="inquiryDeletePro.jsp" onsubmit="return confirm('이 문의를 삭제할까요?');">
                        <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                        <input type="hidden" name="num" value="<%= q.getInquiryNum() %>">
                        <button type="submit" class="sp-btn small danger">문의 삭제</button>
                    </form>
                <% } %>
            </div>
        </details>
    <% } %>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
