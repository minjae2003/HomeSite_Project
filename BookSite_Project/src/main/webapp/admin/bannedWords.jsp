<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.HtmlUtil, filter.BannedWordDAO, java.util.List" %>
<%
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        out.println("<script>alert('관리자만 볼 수 있는 페이지입니다.'); location.href='" + request.getContextPath() + "/main/index.jsp';</script>");
        return;
    }
    List<BannedWordDAO.Word> words = BannedWordDAO.getInstance().list();
    int banCount = 0, allowCount = 0;
    if (words != null) for (BannedWordDAO.Word w : words) { if ("ALLOW".equals(w.type)) allowCount++; else banCount++; }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex">
    <title>금칙어 관리 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/support.css">
    <style>
        .bw-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .bw-list { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px; }
        .bw-chip { display: inline-flex; align-items: center; gap: 6px; padding: 6px 6px 6px 12px; border-radius: 20px; font-size: 14px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .bw-chip.allow { background: #f0fdf4; color: #15803d; border-color: #bbf7d0; }
        .bw-chip form { margin: 0; display: inline; }
        .bw-chip button { border: none; background: rgba(0,0,0,0.06); color: inherit; width: 22px; height: 22px; border-radius: 50%; cursor: pointer; font-size: 13px; line-height: 1; }
        .bw-add { display: flex; gap: 8px; flex-wrap: wrap; }
        .bw-add input[type=text] { flex: 1; min-width: 160px; padding: 10px 12px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 14px; font-family: inherit; }
        .bw-add select { padding: 10px; border: 1px solid #d1d5db; border-radius: 10px; font-family: inherit; }
        .bw-card h2 { font-size: 17px; margin: 0 0 4px; color: #1e293b; }
        .bw-card p.sub { margin: 0; font-size: 13px; color: #64748b; line-height: 1.6; }
        @media (max-width: 768px) { .bw-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<jsp:include page="/module/header.jsp" flush="false"/>

<div class="sp-wrap wide">
    <div class="sp-head">
        <div>
            <h1>🚫 금칙어 관리</h1>
            <p>글 제목·본문, 댓글, 닉네임, 프로필 소개에 금칙어가 있으면 저장되지 않아요. (관리자 계정은 검사하지 않음)</p>
        </div>
        <a class="sp-link" href="inquiries.jsp">문의 관리 ›</a>
    </div>

    <% if (words == null) { %>
        <div class="sp-card sp-note">금칙어 목록을 불러오지 못했어요. 서버 DB에 BANNED_WORD 테이블이 있는지 확인해 주세요.</div>
    <% } else { %>

    <div class="sp-card bw-card" style="margin-bottom:16px;">
        <h2>단어 추가</h2>
        <p class="sub" style="margin-bottom:12px;">
            띄어쓰기·숫자·기호를 끼워 넣은 우회 표현(예: "시 발", "시1발")도 함께 걸러져요.<br>
            정상적인 단어가 걸리면 <b>예외 단어</b>로 추가하세요. (예: "시발점"을 예외로 두면 "시발점"은 통과)
        </p>
        <form class="bw-add" method="post" action="bannedWordPro.jsp">
            <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
            <input type="hidden" name="action" value="add">
            <select name="type">
                <option value="BAN">금칙어</option>
                <option value="ALLOW">예외 단어</option>
            </select>
            <input type="text" name="word" maxlength="50" placeholder="추가할 단어" required>
            <button type="submit" class="sp-btn primary small">추가</button>
        </form>
        <% if (banCount == 0) { %>
        <form method="post" action="bannedWordPro.jsp" style="margin-top:12px;">
            <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
            <input type="hidden" name="action" value="defaults">
            <button type="submit" class="sp-btn gray small">기본 목록 넣기 (욕설·도박 광고 <%= BannedWordDAO.DEFAULT_BAN.length %>개 + 예외 <%= BannedWordDAO.DEFAULT_ALLOW.length %>개)</button>
        </form>
        <% } %>
    </div>

    <div class="bw-grid">
        <div class="sp-card bw-card">
            <h2>금칙어 <small style="color:#94a3b8;"><%= banCount %>개</small></h2>
            <div class="bw-list">
            <% for (BannedWordDAO.Word w : words) { if ("ALLOW".equals(w.type)) continue; %>
                <span class="bw-chip"><%= HtmlUtil.esc(w.word) %>
                    <form method="post" action="bannedWordPro.jsp" onsubmit="return confirm('삭제할까요?');">
                        <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= w.id %>">
                        <button type="submit" title="삭제">×</button>
                    </form>
                </span>
            <% } %>
            <% if (banCount == 0) { %><p class="sub">등록된 금칙어가 없어요.</p><% } %>
            </div>
        </div>
        <div class="sp-card bw-card">
            <h2>예외 단어 <small style="color:#94a3b8;"><%= allowCount %>개</small></h2>
            <div class="bw-list">
            <% for (BannedWordDAO.Word w : words) { if (!"ALLOW".equals(w.type)) continue; %>
                <span class="bw-chip allow"><%= HtmlUtil.esc(w.word) %>
                    <form method="post" action="bannedWordPro.jsp" onsubmit="return confirm('삭제할까요?');">
                        <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= w.id %>">
                        <button type="submit" title="삭제">×</button>
                    </form>
                </span>
            <% } %>
            <% if (allowCount == 0) { %><p class="sub">등록된 예외 단어가 없어요.</p><% } %>
            </div>
        </div>
    </div>
    <% } %>
</div>

<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
