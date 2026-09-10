<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>
<%@ page import="board.BoardVO" %>
<%@ page import="reply.ReplyDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category");
    if(category == null || category.trim().equals("")) category = "all";

    SimpleDateFormat sdf = new SimpleDateFormat("MM.dd");
    BoardDAO dao = BoardDAO.getInstance();
    ReplyDAO rdao = ReplyDAO.getInstance();

    // MySQL 페이징 설정
    int pageSize = 10;
    String pageNum = request.getParameter("pageNum");
    if(pageNum == null) pageNum = "1";

    int currentPage = Integer.parseInt(pageNum);
    int startRow = (currentPage - 1) * pageSize; // MySQL LIMIT 오프셋 (0부터 시작)

    int count = dao.getBoardCount("FREE", category);
    List<BoardVO> boardList = null;

    if(count > 0) {
        boardList = dao.getBoards("FREE", category, startRow, pageSize);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>자유게시판</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/freeboard.css">
</head>
<body>

    <jsp:include page="/module/header.jsp" flush="false"/>

    <div class="container">
        <main class="main-content">
            <div class="board-header">
                <h1 class="board-title">💬 자유게시판</h1>
                <p class="board-desc">자취생들과 소통하는 공간입니다.</p>
            </div>

            <!-- 카테고리 필터 -->
            <div class="category-filter">
                <a href="list.jsp?category=all" class="filter-btn <%= category.equals("all") ? "active" : "" %>">전체보기</a>
                <a href="list.jsp?category=popular" class="filter-btn <%= category.equals("popular") ? "active" : "" %>">🔥 인기글</a>
                <a href="list.jsp?category=tip" class="filter-btn <%= category.equals("tip") ? "active" : "" %>">💡 자취꿀팁</a>
                <a href="list.jsp?category=qna" class="filter-btn <%= category.equals("qna") ? "active" : "" %>">❓ 질문/답변</a>
                <a href="list.jsp?category=free" class="filter-btn <%= category.equals("free") ? "active" : "" %>">🏫 일상/수다</a>
            </div>

            <!-- 목록 테이블 -->
            <div class="board-table-container">
                <table class="board-table">
                    <thead>
                        <tr>
                            <th style="width: 10%;" class="text-center">구분</th>
                            <th style="width: 48%;">제목</th>
                            <th style="width: 16%;">작성자</th>
                            <th style="width: 10%;" class="text-center">날짜</th>
                            <th style="width: 8%;" class="text-center">조회</th>
                            <th style="width: 8%;" class="text-center">추천</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if(count == 0) {
                    %>
                        <tr>
                            <td colspan="6" class="text-center" style="padding: 40px 0; color: #9ca3af;">
                                작성된 게시글이 없습니다.
                            </td>
                        </tr>
                    <%
                        } else if(boardList != null) {
                            for(BoardVO board : boardList) {
                                int rcount = rdao.getReplyCount(board.getNum());
                    %>
                        <tr>
                            <td class="text-center">
                                <span class="badge badge-free"><%= board.getCategory() != null ? board.getCategory() : "자유" %></span>
                            </td>
                            <td>
                                <a href="content.jsp?num=<%= board.getNum() %>&pageNum=<%= currentPage %>&category=<%= category %>" class="post-title-link">
                                    <%= board.getSubject() %>
                                </a>
                                <% if(rcount > 0) { %>
                                    <span class="comment-count">[<%= rcount %>]</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="author-box"><%= board.getWriterNickname() %></div>
                            </td>
                            <td class="text-center text-muted"><%= sdf.format(board.getRegDate()) %></td>
                            <td class="text-center text-muted"><%= board.getReadcount() %></td>
                            <td class="text-center font-bold"><%= board.getLikeCount() %></td>
                        </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>

            <!-- 하단 페이징 및 글쓰기 버튼 -->
            <div class="board-footer">
                <div class="pagination">
                <%
                    if(count > 0) {
                        int pageCount = count / pageSize + (count % pageSize == 0 ? 0 : 1);
                        int pageBlock = 10;
                        int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
                        int endPage = startPage + pageBlock - 1;
                        if(endPage > pageCount) endPage = pageCount;

                        if(startPage > pageBlock) {
                %>
                            <a href="list.jsp?category=<%= category %>&pageNum=<%= startPage - pageBlock %>" class="page-btn">&lt;</a>
                <%
                        }
                        for(int i = startPage; i <= endPage; i++) {
                %>
                            <a href="list.jsp?category=<%= category %>&pageNum=<%= i %>" class="page-btn <%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
                <%
                        }
                        if(endPage < pageCount) {
                %>
                            <a href="list.jsp?category=<%= category %>&pageNum=<%= startPage + pageBlock %>" class="page-btn">&gt;</a>
                <%
                        }
                    }
                %>
                </div>

                <%
                    String sessionUserId = (String) session.getAttribute("id");
                    if(sessionUserId == null) {
                %>
                    <a href="javascript:alert('로그인 후 이용 가능합니다.'); location.href='${pageContext.request.contextPath}/member/loginForm.jsp';" class="btn-write">✏️ 글쓰기</a>
                <% } else { %>
                    <a href="writeForm.jsp?category=<%= category %>" class="btn-write">✏️ 글쓰기</a>
                <% } %>
            </div>
        </main>
    </div>

    <jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>