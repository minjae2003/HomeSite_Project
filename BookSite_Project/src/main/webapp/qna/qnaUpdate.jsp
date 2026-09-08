<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="qna.QnaDAO, qna.QnaDTO" %>
<%
    int num = Integer.parseInt(request.getParameter("num"));
    String pageNum = request.getParameter("pageNum");
    if (pageNum == null) pageNum = "1";

    QnaDAO dao = QnaDAO.getInstance();
    QnaDTO article = dao.getQnaArticle(num);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q & A 글 수정</title>
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

    .write-table { width: 100%; border-collapse: collapse; font-size: 13px; border-top: 1px solid #ddd; border-bottom: 1px solid #ddd; }
    .write-table th { width: 18%; padding: 18px 0; text-align: center; font-weight: bold; color: #000; border-bottom: 1px solid #e0e0e0; vertical-align: middle; }
    .write-table td { width: 82%; padding: 12px 10px; border-bottom: 1px solid #e0e0e0; }

    .input-text { width: 100%; height: 32px; border: 1px solid #a6a6a6; padding: 0 8px; font-size: 13px; outline: none; }
    .input-textarea { width: 100%; height: 220px; border: 1px solid #a6a6a6; padding: 8px; font-size: 13px; resize: vertical; outline: none; }

    .btn-container { text-align: right; margin-top: 20px; }
    .btn-style { background-color: #ffffff; border: 1px solid #b0b0b0; padding: 5px 16px; font-size: 12px; cursor: pointer; color: #333; margin-left: 4px; }
    .btn-style:hover { background-color: #f0f0f0; }
</style>
</head>
<body>

    <%@ include file="/module/header.jsp" %>

    <div class="content-body">
        <div class="sub-title">Q & A ＞ 글 수정</div>

        <form action="qnaUpdatePro.jsp" method="post">
            <input type="hidden" name="num" value="<%= article.getNum() %>">
            <input type="hidden" name="pageNum" value="<%= pageNum %>">

            <table class="write-table">
                <tr>
                    <th>작 성 자</th>
                    <td>
                        <input type="text" name="writer" class="input-text" value="<%= article.getWriter() %>" readonly style="background-color: #f5f5f5;">
                    </td>
                </tr>
                <tr>
                    <th>제 &nbsp; 목</th>
                    <td>
                        <input type="text" name="subject" class="input-text" value="<%= article.getSubject() %>" required>
                    </td>
                </tr>
                <tr>
                    <th>내 &nbsp; 용</th>
                    <td>
                        <textarea name="content" class="input-textarea" required><%= article.getContent() %></textarea>
                    </td>
                </tr>
            </table>

            <div class="btn-container">
                <button type="submit" class="btn-style">수정완료</button>
                <button type="button" class="btn-style" onclick="location.href='qnaDetail.jsp?num=<%= article.getNum() %>&pageNum=<%= pageNum %>'">취소</button>
            </div>
        </form>
    </div>

</body>
</html>