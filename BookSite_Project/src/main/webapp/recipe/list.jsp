<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, java.util.List, java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    String sessionUserNick = (String) session.getAttribute("nickname");
    if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");

    // 요리레시피 게시판은 board_type='RECIPE' 단일 카테고리만 사용
    final String CATEGORY = "RECIPE";

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
    int totalCount = dao.getArticleCount(CATEGORY, keyword);

    List<BoardVO> articleList = null;
    if (totalCount > 0) {
        articleList = dao.getArticles(startRow, pageSize, CATEGORY, keyword);
    }

    // 페이징 링크에 검색어를 그대로 이어붙이기 위한 쿼리스트링 조각
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
    <title>요리레시피 - 자취의 품격</title>
  
    <link rel="stylesheet" href="../css/recipe/list.css">
</head>
<body>
<jsp:include page="../module/header.jsp" flush="false"/>

<div class="container">
    <!-- 게시판 헤더 -->
    <div class="board-header">
        <h1 class="board-title">🍳 요리레시피</h1>
        <p class="board-subtitle">자취생들을 위한 간단하고 맛있는 집밥 레시피를 공유하는 공간입니다.</p>
    </div>

    <!-- 검색창 -->
    <form class="search-box" action="list.jsp" method="get">
        <input type="text" name="keyword" placeholder="레시피 제목/내용으로 검색" value="<%= escapedKeyword %>">
        <button type="submit">🔍 검색</button>
    </form>
    <% if (keyword != null && !keyword.isEmpty()) { %>
        <div class="search-result-info">
            '<b><%= escapedKeyword %></b>' 검색 결과 <b><%= totalCount %></b>건
            <a href="list.jsp" style="margin-left: 8px; color: #94a3b8; text-decoration: underline;">검색 초기화</a>
        </div>
    <% } %>

    <div class="top-bar">
        <span style="font-size: 14px; color: #666;">
            총 <b><%= totalCount %></b>개의 레시피
        </span>
        <a href="writeForm.jsp" class="btn-write">✏️ 레시피 등록</a>
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
                    <td colspan="4" style="text-align: center; padding: 40px; color: #999;">
                        <%= (keyword != null && !keyword.isEmpty()) ? "검색 결과가 없습니다." : "등록된 레시피가 없습니다. 첫 레시피를 올려보세요!" %>
                    </td>
                </tr>
                <%
                    } else {
                        for (BoardVO article : articleList) {
                            String dateStr = article.getRegDate() != null ? sdf.format(article.getRegDate()) : "";
                %>
                <tr>
                    <td>
                        <span class="cat-badge">레시피</span>
                        <a href="content.jsp?num=<%= article.getNum() %>&pageNum=<%= pageNum %><%= keywordQuery %>" class="subject-link">
                            <%= article.getSubject() %>
                        </a>

                        <!-- 댓글 수 표시 -->
                        <% if (article.getCommentCount() > 0) { %>
                            <span class="comment-cnt">[💬 <%= article.getCommentCount() %>]</span>
                        <% } %>

                        <!-- 추천 수 표시 -->
                        <% if (article.getLikeCount() > 0) { %>
                            <span style="font-size: 12px; color: #e53935; font-weight: 700; margin-left: 4px;">[❤️ <%= article.getLikeCount() %>]</span>
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

    <!-- 페이징 영역 -->
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
            <a href="list.jsp?pageNum=<%= startPage - pageBlock %><%= keywordQuery %>" class="page-link">이전</a>
        <% } %>

        <% for (int i = startPage; i <= endPage; i++) { %>
            <a href="list.jsp?pageNum=<%= i %><%= keywordQuery %>" class="page-link <%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
        <% } %>

        <% if (endPage < pageCount) { %>
            <a href="list.jsp?pageNum=<%= startPage + pageBlock %><%= keywordQuery %>" class="page-link">다음</a>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>
