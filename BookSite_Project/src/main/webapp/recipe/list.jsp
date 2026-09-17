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
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Pretendard', 'Malgun Gothic', sans-serif; background-color: #f7f9fa; color: #333; line-height: 1.5; }
        a { text-decoration: none; color: inherit; }

        .container { max-width: 1000px; margin: 35px auto; padding: 0 20px; }

        /* 1. 게시판 상단 제목 & 설명 영역 */
        .board-header { margin-bottom: 24px; }
        .board-title { font-size: 28px; font-weight: 800; color: #1e293b; display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
        .board-subtitle { font-size: 15px; color: #64748b; font-weight: 400; }

        /* 2. 게시글 목록 영역 */
        .board-card { background: #fff; border-radius: 12px; border: 1px solid #eaeaea; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.02); }

        .board-table { width: 100%; border-collapse: collapse; text-align: left; font-size: 14px; }
        .board-table th { background: #f8f9fa; padding: 14px 16px; border-bottom: 1px solid #eaeaea; color: #555; font-weight: 700; }
        .board-table td { padding: 14px 16px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
        .board-table tr:hover { background-color: #fdfdfd; }

        .cat-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; background: #e8f5e9; color: #2e7d32; margin-right: 6px; }

        .subject-link { color: #2d3436; font-weight: 600; font-size: 15px; }
        .subject-link:hover { color: #4caf50; text-decoration: underline; }

        .comment-cnt { font-size: 13px; font-weight: 700; color: #4caf50; margin-left: 4px; }

        .readcount-text { color: #4caf50; font-weight: 700; }

        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn-write { background: #4caf50; color: #fff; padding: 10px 20px; border-radius: 8px; font-weight: 700; font-size: 14px; }
        .btn-write:hover { background: #388e3c; }

        /* 페이징 */
        .pagination { display: flex; justify-content: center; gap: 5px; margin-top: 25px; }
        .page-link { padding: 8px 12px; border-radius: 6px; border: 1px solid #ddd; background: #fff; color: #555; font-size: 13px; font-weight: 600; }
        .page-link.active { background: #2e7d32; color: #fff; border-color: #2e7d32; }

        /* 검색 */
        .search-box {
            display: flex;
            align-items: center;
            gap: 0;
            margin-bottom: 20px;
            background: #fff;
            border: 1.5px solid #e2e8f0;
            border-radius: 30px;
            padding: 4px 4px 4px 18px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .search-box:focus-within {
            border-color: #4caf50;
            box-shadow: 0 4px 14px rgba(76, 175, 80, 0.15);
        }
        .search-box input {
            flex: 1;
            border: none;
            outline: none;
            padding: 10px 6px;
            font-size: 14px;
            background: transparent;
        }
        .search-box input::placeholder { color: #94a3b8; }
        .search-box button {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: linear-gradient(135deg, #66bb6a, #388e3c);
            color: #fff;
            border: none;
            border-radius: 26px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: opacity 0.2s ease, transform 0.15s ease;
        }
        .search-box button:hover { opacity: 0.9; transform: translateY(-1px); }
        .search-result-info { font-size: 14px; color: #64748b; margin-bottom: 12px; }
        .search-result-info b { color: #4caf50; }
    </style>
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
