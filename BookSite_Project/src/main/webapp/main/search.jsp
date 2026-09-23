<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, java.util.List, java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("keyword");
    if (keyword != null) keyword = keyword.trim();

    int pageSize = 10;
    String pageNum = request.getParameter("pageNum");
    if (pageNum == null) pageNum = "1";
    int currentPage = Integer.parseInt(pageNum);
    int startRow = (currentPage - 1) * pageSize;

    BoardDAO dao = BoardDAO.getInstance();

    // 게시글 검색: 자유게시판(FREE/TIP/QNA) + 요리레시피(RECIPE) - "ALL"은 공지사항만 제외한 전체 카테고리
    int postTotal = 0;
    List<BoardVO> postList = null;

    // 공지사항 검색: 최근 5건만 미리보기로 보여주고 "더보기"는 공지게시판으로
    int noticeTotal = 0;
    List<BoardVO> noticeList = null;

    if (keyword != null && !keyword.isEmpty()) {
        postTotal = dao.getArticleCount("ALL", keyword);
        if (postTotal > 0) {
            postList = dao.getArticles(startRow, pageSize, "ALL", keyword);
        }
        noticeTotal = dao.getNoticeCount("ALL", keyword);
        if (noticeTotal > 0) {
            noticeList = dao.getNotices(0, 5, "ALL", keyword);
        }
    }

    String escapedKeyword = "";
    if (keyword != null) {
        escapedKeyword = keyword.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    String keywordQuery = "";
    if (keyword != null && !keyword.isEmpty()) {
        try {
            keywordQuery = "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            keywordQuery = "";
        }
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= (keyword != null && !keyword.isEmpty()) ? ("'" + keyword + "' 검색결과") : "통합검색" %> - 자취의 품격</title>
    <link rel="stylesheet" href="../css/main/search.css">
</head>
<body>
<jsp:include page="../module/header.jsp" flush="false"/>

<div class="container">
    <div class="board-header">
        <h1 class="board-title">🔍 통합검색</h1>
        <p class="board-subtitle">자유게시판, 자취꿀팁, 질문/답변, 요리레시피, 공지사항을 한 번에 검색합니다.</p>
    </div>

    <form class="search-box" action="search.jsp" method="get">
        <input type="text" name="keyword" placeholder="검색어를 입력하세요" value="<%= escapedKeyword %>" autofocus>
        <button type="submit">🔍 검색</button>
    </form>

    <% if (keyword == null || keyword.isEmpty()) { %>
        <div class="empty-msg">검색어를 입력해 주세요.</div>
    <% } else if (postTotal == 0 && noticeTotal == 0) { %>
        <div class="empty-msg">'<%= escapedKeyword %>'에 대한 검색 결과가 없습니다.</div>
    <% } else { %>

        <% if (noticeTotal > 0) { %>
        <div class="result-section">
            <div class="result-section-title">
                <span>📢 공지사항 <span class="count">(<%= noticeTotal %>)</span></span>
                <a href="../noticeboard/list.jsp?category=ALL<%= keywordQuery %>" class="more-link">더보기 +</a>
            </div>
            <div class="board-card">
                <ul class="notice-list">
                    <% for (BoardVO n : noticeList) {
                        boolean isFixed = "FIX".equals(n.getNoticeType());
                    %>
                    <li>
                        <span class="cat-badge NOTICE"><%= isFixed ? "📌 고정" : "일반" %></span>
                        <a href="../noticeboard/content.jsp?num=<%= n.getNum() %>&category=ALL" class="subject-link"><%= n.getSubject() %></a>
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>

        <% if (postTotal > 0) { %>
        <div class="result-section">
            <div class="result-section-title">
                <span>💬 게시글 <span class="count">(<%= postTotal %>)</span></span>
            </div>
            <div class="board-card">
                <table class="board-table">
                    <thead>
                        <tr>
                            <th style="width: 58%;">제목</th>
                            <th style="width: 16%;">작성자</th>
                            <th style="width: 16%;">작성일</th>
                            <th style="width: 10%; text-align: center;">조회수</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BoardVO p : postList) {
                            String catCode = p.getCategory();
                            String catName = "일상";
                            if ("TIP".equals(catCode)) catName = "꿀팁";
                            else if ("QNA".equals(catCode)) catName = "질문";
                            else if ("RECIPE".equals(catCode)) catName = "레시피";
                            String contentUrl = "RECIPE".equals(catCode)
                                    ? "../recipe/content.jsp?num=" + p.getNum()
                                    : "../freeboard/content.jsp?num=" + p.getNum();
                            String dateStr = p.getRegDate() != null ? sdf.format(p.getRegDate()) : "";
                        %>
                        <tr>
                            <td>
                                <span class="cat-badge <%= catCode %>"><%= catName %></span>
                                <a href="<%= contentUrl %>" class="subject-link"><%= p.getSubject() %></a>
                            </td>
                            <td><%= p.getWriterNickname() != null ? p.getWriterNickname() : p.getWriter() %></td>
                            <td><%= dateStr %></td>
                            <td style="text-align: center;">👁️ <%= p.getReadcount() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <%
                int pageCount = postTotal / pageSize + (postTotal % pageSize == 0 ? 0 : 1);
                int pageBlock = 5;
                int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
                int endPage = startPage + pageBlock - 1;
                if (endPage > pageCount) endPage = pageCount;
                if (pageCount > 1) {
            %>
            <div class="pagination">
                <% if (startPage > pageBlock) { %>
                    <a href="search.jsp?pageNum=<%= startPage - pageBlock %><%= keywordQuery %>" class="page-link">이전</a>
                <% } %>
                <% for (int i = startPage; i <= endPage; i++) { %>
                    <a href="search.jsp?pageNum=<%= i %><%= keywordQuery %>" class="page-link <%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
                <% } %>
                <% if (endPage < pageCount) { %>
                    <a href="search.jsp?pageNum=<%= startPage + pageBlock %><%= keywordQuery %>" class="page-link">다음</a>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>

    <% } %>
</div>

</body>
</html>
