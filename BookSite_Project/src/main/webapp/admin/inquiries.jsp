<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil, inquiry.InquiryDAO, inquiry.InquiryVO, java.util.List" %>
<%
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        out.println("<script>alert('관리자만 볼 수 있는 페이지입니다.'); location.href='" + request.getContextPath() + "/main/index.jsp';</script>");
        return;
    }
    String status = request.getParameter("status");
    if (!"WAIT".equals(status) && !"DONE".equals(status)) status = "ALL";
    String pageNum = request.getParameter("pageNum");
    int currentPage = (pageNum != null && pageNum.matches("\\d{1,6}")) ? Math.max(1, Integer.parseInt(pageNum)) : 1;
    int pageSize = 20;

    InquiryDAO dao = InquiryDAO.getInstance();
    int waitCount = dao.countAll("WAIT");
    int total = dao.countAll(status);
    List<InquiryVO> list = dao.listAll(status, (currentPage - 1) * pageSize, pageSize);
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>문의 관리 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/support.css">
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="sp-wrap wide">
    <div class="sp-head">
        <div>
            <h1>🛠 문의 관리</h1>
            <p>답변 대기 <b style="color:#f97316;"><%= Math.max(0, waitCount) %></b>건 · 답변을 저장하면 문의한 회원에게 알림이 가요.</p>
        </div>
    </div>

    <nav class="sp-tabs">
        <a href="inquiries.jsp?status=ALL" class="<%= "ALL".equals(status) ? "active" : "" %>">전체</a>
        <a href="inquiries.jsp?status=WAIT" class="<%= "WAIT".equals(status) ? "active" : "" %>">답변 대기</a>
        <a href="inquiries.jsp?status=DONE" class="<%= "DONE".equals(status) ? "active" : "" %>">답변 완료</a>
    </nav>

    <% if (list.isEmpty()) { %>
        <div class="sp-card sp-empty">해당하는 문의가 없어요.</div>
    <% } %>
    <% for (InquiryVO q : list) {
           String url = q.getPageUrl();
           boolean linkable = url != null && url.matches("^(https?://|/)\\S*$");
    %>
        <details class="sp-item <%= q.isDone() ? "" : "wait" %>" <%= q.isDone() ? "" : "open" %>>
            <summary>
                <span class="sp-badge <%= q.isDone() ? "done" : "wait" %>"><%= q.isDone() ? "답변 완료" : "답변 대기" %></span>
                <span class="sp-badge cat"><%= HtmlUtil.esc(q.getCategoryName()) %></span>
                <span class="sp-subject"><%= HtmlUtil.esc(q.getSubject()) %></span>
                <span class="sp-meta"><%= HtmlUtil.esc(q.getUserNickname()) %> (<%= HtmlUtil.esc(q.getUserId()) %>) · <%= q.getRegDateText() %></span>
            </summary>
            <div class="sp-body">
                <p class="sp-text"><%= HtmlUtil.esc(q.getContent()) %></p>
                <% if (url != null) { %>
                    <div class="sp-url">관련 주소:
                        <% if (linkable) { %><a href="<%= HtmlUtil.esc(url) %>" target="_blank" rel="noopener noreferrer nofollow"><%= HtmlUtil.esc(url) %></a>
                        <% } else { %><%= HtmlUtil.esc(url) %><% } %>
                    </div>
                <% } %>
                <% if (q.isDone()) { %>
                    <div class="sp-answer">
                        <h4>✉️ 보낸 답변 · <%= HtmlUtil.esc(q.getAnsweredBy()) %> · <%= q.getAnsweredAtText() %></h4>
                        <p class="sp-text"><%= HtmlUtil.esc(q.getAnswer()) %></p>
                    </div>
                <% } %>
                <form class="sp-answer-form" method="post" action="inquiryAnswerPro.jsp"
                      onsubmit="if (this.answer.value.trim().length < 2) { alert('답변을 입력해 주세요.'); return false; } return true;">
                    <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                    <input type="hidden" name="num" value="<%= q.getInquiryNum() %>">
                    <input type="hidden" name="status" value="<%= status %>">
                    <input type="hidden" name="pageNum" value="<%= currentPage %>">
                    <textarea name="answer" maxlength="2000" placeholder="<%= q.isDone() ? "답변을 고치려면 새로 입력해 저장하세요 (회원에게 다시 알림이 가요)" : "답변을 입력하세요" %>"></textarea>
                    <div class="sp-row-actions">
                        <button type="submit" class="sp-btn small primary"><%= q.isDone() ? "답변 수정" : "답변 저장" %></button>
                    </div>
                </form>
            </div>
        </details>
    <% } %>

    <% if (pageCount > 1) { %>
    <div class="sp-paging">
        <% for (int i = 1; i <= pageCount; i++) { %>
            <a href="inquiries.jsp?status=<%= status %>&pageNum=<%= i %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
        <% } %>
    </div>
    <% } %>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
