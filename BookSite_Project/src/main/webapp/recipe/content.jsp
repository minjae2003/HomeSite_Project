<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, board.CommentDAO, board.CommentVO, upload.BoardFileDAO, upload.BoardFileVO, java.util.List, java.text.SimpleDateFormat" %>
<%!
    private String escAttr(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
    }
    private String formatSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return String.format("%.1f MB", bytes / (1024.0 * 1024.0));
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) sessionUserId = (String) session.getAttribute("userId");
    if (sessionUserId == null) sessionUserId = (String) session.getAttribute("memberId");

    String numParam = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");

    if (pageNum == null) pageNum = "1";

    if (numParam == null || numParam.trim().isEmpty()) {
        response.sendRedirect("list.jsp");
        return;
    }

    int num = Integer.parseInt(numParam);

    BoardDAO dao = BoardDAO.getInstance();
    dao.updateReadcount(num); // 조회수 증가
    BoardVO article = dao.getBoardDetail(num);

    if (article == null) {
        out.println("<script>alert('존재하지 않는 레시피입니다.'); location.href='list.jsp';</script>");
        return;
    }

    boolean isLiked = dao.hasUserLiked(num, sessionUserId);

    // 댓글 목록 가져오기
    CommentDAO commentDao = CommentDAO.getInstance();
    List<CommentVO> commentList = commentDao.getComments(num);

    // 첨부파일 가져오기 + 본문 [img1]/[video1] 위치에 삽입, 매칭 안 된 파일은 맨 아래에 모아서 첨부
    // 일반 문서(FILE 타입: hwp/pdf/워드/압축파일 등)는 본문 삽입 없이 별도 첨부파일 목록으로만 표시
    List<BoardFileVO> fileList = BoardFileDAO.getInstance().getFiles(num);
    List<BoardFileVO> docFiles = new java.util.ArrayList<BoardFileVO>();
    String processedContent = article.getContent() != null ? article.getContent() : "";
    StringBuilder extraMedia = new StringBuilder();
    int imgIdx = 0, vidIdx = 0;
    for (BoardFileVO f : fileList) {
        if (f.isFile()) {
            docFiles.add(f);
            continue;
        }
        String url = request.getContextPath() + f.getWebPath();
        String tag;
        String placeholder;
        if (f.isImage()) {
            imgIdx++;
            placeholder = "[img" + imgIdx + "]";
            tag = "<img src=\"" + url + "\" alt=\"" + escAttr(f.getOriginalName()) + "\" class=\"post-media\">";
        } else {
            vidIdx++;
            placeholder = "[video" + vidIdx + "]";
            tag = "<video src=\"" + url + "\" controls class=\"post-media\"></video>";
        }
        if (processedContent.contains(placeholder)) {
            processedContent = processedContent.replace(placeholder, tag);
        } else {
            extraMedia.append(tag);
        }
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= article.getSubject() %> - 자취의 품격</title>
    <link rel="stylesheet" href="../css/recipe/content.css">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false"/>

<div class="container">
    <!-- 본문 카드 -->
    <div class="card">
        <h1 class="post-title">🍳 <%= article.getSubject() %></h1>
        <div class="post-meta">
            <span>작성자: <b><%= article.getWriterNickname() != null ? article.getWriterNickname() : article.getWriter() %></b></span>
            <span>작성일: <%= article.getRegDate() != null ? sdf.format(article.getRegDate()) : "" %></span>
            <span>조회수: <%= article.getReadcount() %></span>
        </div>
        <div class="post-content"><%= processedContent %><%= extraMedia.toString() %></div>

        <% if (!docFiles.isEmpty()) { %>
        <ul class="attach-list">
            <% for (BoardFileVO f : docFiles) { %>
            <li>
                <a href="<%= request.getContextPath() + f.getWebPath() %>" download="<%= escAttr(f.getOriginalName()) %>">
                    📎 <%= f.getOriginalName() %> <span class="attach-size">(<%= formatSize(f.getFileSize()) %>)</span>
                </a>
            </li>
            <% } %>
        </ul>
        <% } %>

        <div class="btn-box">
            <!-- 추천 버튼 -->
            <button class="btn btn-like <%= isLiked ? "active" : "" %>"
                    onclick="location.href='likePro.jsp?num=<%= num %>&pageNum=<%= pageNum %>'">
                <%= isLiked ? "❤️ 추천취소" : "🤍 추천하기" %> <b><%= article.getLikeCount() %></b>
            </button>

            <div>
                <% if (sessionUserId != null && sessionUserId.equals(article.getWriterId())) { %>
                    <button class="btn" style="background:#f1f5f9;" onclick="location.href='updateForm.jsp?num=<%= num %>&pageNum=<%= pageNum %>'">수정</button>
                    <button class="btn" style="background:#fee2e2; color:#dc2626;" onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='deletePro.jsp?num=<%= num %>&pageNum=<%= pageNum %>'">삭제</button>
                <% } %>
                <button class="btn btn-list" onclick="location.href='list.jsp?pageNum=<%= pageNum %>'">목록</button>
            </div>
        </div>
    </div>

    <!-- 댓글 카드 -->
    <div class="comment-section">
        <h3 class="comment-header">💬 댓글 <span>(<%= commentList.size() %>)</span></h3>

        <!-- 댓글 작성 폼 -->
        <form action="commentWritePro.jsp" method="post" class="comment-form">
            <input type="hidden" name="boardNum" value="<%= num %>">
            <input type="hidden" name="pageNum" value="<%= pageNum %>">
            <textarea name="content" class="comment-textarea" placeholder="<%= sessionUserId == null ? "로그인 후 댓글 작성이 가능합니다." : "레시피에 대한 후기나 팁을 남겨주세요." %>" <%= sessionUserId == null ? "disabled" : "" %> required></textarea>
            <button type="submit" class="btn-comment-submit" <%= sessionUserId == null ? "disabled" : "" %>>등록</button>
        </form>

        <!-- 댓글 목록 -->
        <ul class="comment-list">
            <% if (commentList.isEmpty()) { %>
                <li style="text-align: center; color: #94a3b8; padding: 20px 0; font-size: 14px;">첫 번째 댓글을 작성해 보세요!</li>
            <% } else {
                for (CommentVO comment : commentList) {
            %>
                <li class="comment-item">
                    <div class="comment-top">
                        <span class="comment-writer">
                            <%= comment.getWriterNickname() != null ? comment.getWriterNickname() : comment.getWriter() %>
                        </span>
                        <div>
                            <span class="comment-date"><%= sdf.format(comment.getRegDate()) %></span>
                            <% if (sessionUserId != null && sessionUserId.equals(comment.getWriterId())) { %>
                                <button class="btn-comment-del" onclick="if(confirm('댓글을 삭제하시겠습니까?')) location.href='commentDeletePro.jsp?commentNum=<%= comment.getCommentNum() %>&boardNum=<%= num %>&pageNum=<%= pageNum %>'">삭제</button>
                            <% } %>
                        </div>
                    </div>
                    <div class="comment-text"><%= comment.getContent() %></div>
                </li>
            <%
                }
            }
            %>
        </ul>
    </div>
</div>

</body>
</html>
