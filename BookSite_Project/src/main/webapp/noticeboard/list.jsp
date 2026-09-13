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

    // 페이징 처리
    int pageSize = 10;
    String pageNum = request.getParameter("pageNum");
    if (pageNum == null) pageNum = "1";

    int currentPage = Integer.parseInt(pageNum);
    int startRow = (currentPage - 1) * pageSize;

    BoardDAO dao = BoardDAO.getInstance();
    int totalCount = dao.getNoticeCount(category);

    List<BoardVO> articleList = null;
    if (totalCount > 0) {
        articleList = dao.getNotices(startRow, pageSize, category);
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 - 자취의 품격</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Pretendard', 'Malgun Gothic', sans-serif; background-color: #f7f9fa; color: #333; line-height: 1.5; }
        a { text-decoration: none; color: inherit; }

        .navbar { background: #fff; border-bottom: 1px solid #eaeaea; padding: 15px 0; }
        .nav-container { max-width: 1000px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; }
        .logo { font-size: 20px; font-weight: 800; color: #ff5722; display: flex; align-items: center; gap: 8px; }

        .container { max-width: 1000px; margin: 35px auto; padding: 0 20px; }

        .board-header { margin-bottom: 24px; }
        .board-title { font-size: 28px; font-weight: 800; color: #1e293b; display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
        .board-subtitle { font-size: 15px; color: #64748b; font-weight: 400; }

        .category-tabs { display: flex; align-items: center; gap: 12px; margin-bottom: 28px; flex-wrap: wrap; }
        .tab-item { padding: 9px 20px; border-radius: 25px; font-size: 14px; font-weight: 700; color: #64748b; background: transparent; transition: all 0.2s ease; display: inline-flex; align-items: center; gap: 6px; }
        .tab-item:hover { color: #1e293b; background-color: #f1f5f9; }
        .tab-item.active { background: #2b374e; color: #ffffff !important; box-shadow: 0 4px 12px rgba(43, 55, 78, 0.25); }

        .board-card { background: #fff; border-radius: 12px; border: 1px solid #eaeaea; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.02); }

        .board-table { width: 100%; border-collapse: collapse; text-align: left; font-size: 14px; }
        .board-table th { background: #f8f9fa; padding: 14px 16px; border-bottom: 1px solid #eaeaea; color: #555; font-weight: 700; }
        .board-table td { padding: 14px 16px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
        .board-table tr:hover { background-color: #fdfdfd; }
        .board-table tr.fixed-row { background-color: #fff8f6; }

        .cat-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; background: #edf2f7; color: #4a5568; margin-right: 6px; }
        .cat-badge.FIX { background: #ffebee; color: #c62828; }
        .cat-badge.NORMAL { background: #e3f2fd; color: #1565c0; }

        .subject-link { color: #2d3436; font-weight: 600; font-size: 15px; }
        .subject-link:hover { color: #ff5722; text-decoration: underline; }

        .comment-cnt { font-size: 13px; font-weight: 700; color: #ff5722; margin-left: 4px; }

        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .btn-write { background: #ff5722; color: #fff; padding: 10px 20px; border-radius: 8px; font-weight: 700; font-size: 14px; }
        .btn-write:hover { background: #e64a19; }

        .pagination { display: flex; justify-content: center; gap: 5px; margin-top: 25px; }
        .page-link { padding: 8px 12px; border-radius: 6px; border: 1px solid #ddd; background: #fff; color: #555; font-size: 13px; font-weight: 600; }
        .page-link.active { background: #1e272e; color: #fff; border-color: #1e272e; }
    </style>
</head>
<body>
<jsp:include page="../module/header.jsp" flush="false"/>

<div class="container">
    <div class="board-header">
        <h1 class="board-title">📢 공지사항</h1>
        <p class="board-subtitle">운영진의 안내와 중요한 소식을 확인하는 공간입니다.</p>
    </div>

    <div class="category-tabs">
        <a href="list.jsp?category=ALL" class="tab-item <%= "ALL".equals(category) ? "active" : "" %>">전체보기</a>
        <a href="list.jsp?category=FIX" class="tab-item <%= "FIX".equals(category) ? "active" : "" %>">📌 고정공지</a>
        <a href="list.jsp?category=NORMAL" class="tab-item <%= "NORMAL".equals(category) ? "active" : "" %>">📝 일반공지</a>
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
            <a href="list.jsp?pageNum=<%= startPage - pageBlock %>&category=<%= category %>" class="page-link">이전</a>
        <% } %>

        <% for (int i = startPage; i <= endPage; i++) { %>
            <a href="list.jsp?pageNum=<%= i %>&category=<%= category %>" class="page-link <%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
        <% } %>

        <% if (endPage < pageCount) { %>
            <a href="list.jsp?pageNum=<%= startPage + pageBlock %>&category=<%= category %>" class="page-link">다음</a>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>