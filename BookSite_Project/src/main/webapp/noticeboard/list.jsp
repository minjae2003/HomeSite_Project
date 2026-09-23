<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, java.util.List, java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");

    // 공지사항 카테고리 파라미터 (ALL, FIX, NORMAL)
    String category = request.getParameter("category");
    if (category == null || category.trim().isEmpty()) {
        category = "ALL";
    }

    // 검색어 파라미터
    String keyword = request.getParameter("keyword");
    if (keyword != null) keyword = keyword.trim();

    // 페이징 처리
    int pageSize = 10;
    String pageNum = request.getParameter("pageNum");
    if (pageNum == null) pageNum = "1";

    int currentPage = Integer.parseInt(pageNum);
    int startRow = (currentPage - 1) * pageSize;

    BoardDAO dao = BoardDAO.getInstance();
    int totalCount = dao.getNoticeCount(category, keyword);

    List<BoardVO> articleList = null;
    if (totalCount > 0) {
        articleList = dao.getNotices(startRow, pageSize, category, keyword);
    }

    // 페이징/탭 링크에 검색어를 그대로 이어붙이기 위한 쿼리스트링 조각
    String keywordQuery = "";
    if (keyword != null && !keyword.isEmpty()) {
        try {
            keywordQuery = "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            keywordQuery = "";
        }
    }
    // 검색창에 값 채워넣을 때 쓰는 이스케이프 처리 (XSS 방지)
    String escapedKeyword = "";
    if (keyword != null) {
        escapedKeyword = keyword.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 - 자취의 품격</title>
    <link rel="stylesheet" href="../css/noticeboard/list.css">
</head>
<body>
<jsp:include page="../module/header.jsp" flush="false"/>

<div class="container">
    <div class="board-header">
        <h1 class="board-title">📢 공지사항</h1>
        <p class="board-subtitle">운영진의 안내와 중요한 소식을 확인하는 공간입니다.</p>
    </div>

    <!-- 검색창 -->
    <form class="search-box" action="list.jsp" method="get">
        <input type="hidden" name="category" value="<%= category %>">
        <input type="text" name="keyword" placeholder="제목/내용으로 검색" value="<%= escapedKeyword %>">
        <button type="submit">🔍 검색</button>
    </form>
    <% if (keyword != null && !keyword.isEmpty()) { %>
        <div class="search-result-info">
            '<b><%= escapedKeyword %></b>' 검색 결과 <b><%= totalCount %></b>건
            <a href="list.jsp?category=<%= category %>" style="margin-left: 8px; color: #94a3b8; text-decoration: underline;">검색 초기화</a>
        </div>
    <% } %>

    <div class="category-tabs">
        <a href="list.jsp?category=ALL<%= keywordQuery %>" class="tab-item <%= "ALL".equals(category) ? "active" : "" %>">전체보기</a>
        <a href="list.jsp?category=FIX<%= keywordQuery %>" class="tab-item <%= "FIX".equals(category) ? "active" : "" %>">📌 고정공지</a>
        <a href="list.jsp?category=NORMAL<%= keywordQuery %>" class="tab-item <%= "NORMAL".equals(category) ? "active" : "" %>">📝 일반공지</a>
    </div>

    <div class="top-bar">
        <span style="font-size: 14px; color: #666;">
            총 <b><%= totalCount %></b>개의 공지사항
        </span>
        <a href="writeForm.jsp" class="btn-write">✏️ 글쓰기</a>
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
                <%
                    if (totalCount == 0) {
                %>
                <tr>
                    <td colspan="4" style="text-align: center; padding: 40px; color: #999;">등록된 공지사항이 없습니다.</td>
                </tr>
                <%
                    } else {
                        for (BoardVO article : articleList) {
                            String catCode = article.getNoticeType();
                            String catName = "FIX".equals(catCode) ? "고정공지" : "일반공지";
                            boolean isFixed = "FIX".equals(catCode);

                            String dateStr = article.getRegDate() != null ? sdf.format(article.getRegDate()) : "";
                %>
                <tr class="<%= isFixed ? "fixed-row" : "" %>">
                    <td>
                        <span class="cat-badge <%= catCode %>"><%= (isFixed ? "📌 " : "") + catName %></span>
                        <a href="content.jsp?num=<%= article.getNum() %>&pageNum=<%= pageNum %>&category=<%= category %>" class="subject-link">
                            <%= article.getSubject() %>
                        </a>

                        <% if (article.getCommentCount() > 0) { %>
                            <span class="comment-cnt">[💬 <%= article.getCommentCount() %>]</span>
                        <% } %>
                    </td>
                    <td><%= article.getWriterNickname() != null ? article.getWriterNickname() : article.getWriter() %></td>
                    <td><%= dateStr %></td>
                    <td style="text-align: center;">👁️ <%= article.getReadcount() %></td>
                </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
    </div>

    <%
        if (totalCount > 0) {
            int pageCount = totalCount / pageSize + (totalCount % pageSize == 0 ? 0 : 1);
            int pageBlock = 5;
            int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
            int endPage = startPage + pageBlock - 1;
            if (endPage > pageCount) endPage = pageCount;
    %>
    <div class="pagination">
        <% if (startPage > pageBlock) { %>
            <a href="list.jsp?pageNum=<%= startPage - pageBlock %>&category=<%= category %><%= keywordQuery %>" class="page-link">이전</a>
        <% } %>

        <% for (int i = startPage; i <= endPage; i++) { %>
            <a href="list.jsp?pageNum=<%= i %>&category=<%= category %><%= keywordQuery %>" class="page-link <%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
        <% } %>

        <% if (endPage < pageCount) { %>
            <a href="list.jsp?pageNum=<%= startPage + pageBlock %>&category=<%= category %><%= keywordQuery %>" class="page-link">다음</a>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>