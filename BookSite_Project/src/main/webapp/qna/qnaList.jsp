<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO, qna.QnaDTO, java.util.List, java.text.SimpleDateFormat" %>
<%
    int pageSize = 10;
    String pageNum = request.getParameter("pageNum");
    if (pageNum == null) pageNum = "1";
    int currentPage = Integer.parseInt(pageNum);

    QnaDAO dao = QnaDAO.getInstance();
    int count = dao.getArticleCount();
    List<QnaDTO> articleList = null;

    if (count > 0) {
        articleList = dao.getArticles(currentPage, pageSize);
    }

    int number = count - (currentPage - 1) * pageSize;
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q & A 목록</title>
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: '맑은 고딕', 'Malgun Gothic', sans-serif; }

    #top { display: flex; justify-content: space-between; align-items: center; padding: 15px 40px; background-color: #fff; }
    #top h3 a { font-size: 22px; font-weight: bold; color: #000; text-decoration: none; }
    #topmenu { list-style: none; display: flex; align-items: center; gap: 8px; font-size: 12px; color: #333; }
    #topmenu a { color: #333; text-decoration: none; }

    #menubar { background-color: #494158; height: 42px; width: 100%; }
    #menubar ul { list-style: none; display: flex; justify-content: center; align-items: center; height: 100%; }
    #menubar li { margin: 0 35px; }
    #menubar a { color: #ffffff; text-decoration: none; font-weight: bold; font-size: 14px; }

    .content-body { padding: 30px 40px; }
    .sub-title { font-size: 18px; font-weight: bold; margin-bottom: 20px; color: #000; }

    .list-table { width: 100%; border-collapse: collapse; font-size: 13px; text-align: center; border-top: 1px solid #ddd; }
    .list-table th { padding: 12px 0; background-color: #f8f8f8; border-bottom: 1px solid #ddd; font-weight: bold; color: #333; }
    .list-table td { padding: 12px 0; border-bottom: 1px solid #eee; color: #555; }
    .list-table td.title { text-align: left; padding-left: 10px; }
    .list-table td a { color: #333; text-decoration: none; }
    .list-table td a:hover { text-decoration: underline; }

    .btn-container { text-align: right; margin-top: 15px; }
    .btn-style { background-color: #ffffff; border: 1px solid #b0b0b0; padding: 6px 16px; font-size: 12px; cursor: pointer; color: #333; }
    .btn-style:hover { background-color: #f0f0f0; }

    .pagination { text-align: center; margin-top: 25px; font-size: 13px; letter-spacing: 2px; }
    .pagination a { color: #333; text-decoration: none; margin: 0 2px; }
    .pagination a:hover { text-decoration: underline; font-weight: bold; }
    .pagination strong { color: #000; font-weight: bold; margin: 0 2px; }
</style>
</head>
<body>

    <%@ include file="/module/header.jsp" %>

    <div class="content-body">
        <div class="sub-title">Q & A ＞ 글 목록</div>

        <table class="list-table">
            <thead>
                <tr>
                    <th width="8%">번호</th>
                    <th width="50%">제목</th>
                    <th width="15%">작성자</th>
                    <th width="15%">작성일</th>
                    <th width="12%">조회수</th>
                </tr>
            </thead>
            <tbody>
            <%
                if (count > 0 && articleList != null) {
                    for (QnaDTO article : articleList) {
            %>
                <tr>
                    <td><%= number-- %></td>
                    <td class="title">
                        <% if ("Y".equals(article.getSecret())) { %>
                            🔒 <a href="qnaDetail.jsp?num=<%= article.getNum() %>&pageNum=<%= currentPage %>">비밀글입니다.</a>
                        <% } else { %>
                            <a href="qnaDetail.jsp?num=<%= article.getNum() %>&pageNum=<%= currentPage %>">
                                <%= article.getSubject() %>
                            </a>
                        <% } %>
                    </td>
                    <td><%= article.getWriter() %></td>
                    <td><%= sdf.format(article.getReg_date()) %></td>
                    <td><%= article.getReadcount() %></td>
                </tr>
            <%
                    }
                } else {
            %>
                <tr>
                    <td colspan="5">등록된 게시글이 없습니다.</td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>

        <div class="btn-container">
            <button type="button" class="btn-style" onclick="location.href='qnaWrite.jsp'">글쓰기</button>
        </div>

        <div class="pagination">
        <%
            if (count > 0) {
                int pageCount = count / pageSize + (count % pageSize == 0 ? 0 : 1);
                int pageBlock = 10;
                int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
                int endPage = startPage + pageBlock - 1;
                if (endPage > pageCount) endPage = pageCount;

                if (startPage > pageBlock) {
        %>
                    <a href="qnaList.jsp?pageNum=<%= startPage - pageBlock %>">[ 이전 ]</a>
        <%
                }

                for (int i = startPage; i <= endPage; i++) {
                    if (i == currentPage) {
        %>
                        <strong>[ <%= i %> ]</strong>
        <%
                    } else {
        %>
                        <a href="qnaList.jsp?pageNum=<%= i %>">[ <%= i %> ]</a>
        <%
                    }
                }

                if (endPage < pageCount) {
        %>
                    <a href="qnaList.jsp?pageNum=<%= startPage + pageBlock %>">[ 다음 ]</a>
        <%
                }
            }
        %>
        </div>
    </div>

</body>
</html>