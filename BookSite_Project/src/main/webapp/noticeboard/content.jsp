<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, board.CommentDAO, board.CommentVO, upload.BoardFileDAO, upload.BoardFileVO, java.util.List, java.text.SimpleDateFormat" %>
<%!
    // HTML 본문/속성 안에 안전하게 넣기 위한 이스케이프 (XSS 방지)
    private String escAttr(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;")
                .replace("<", "&lt;").replace(">", "&gt;");
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
    boolean isAdminUser = "ADMIN".equals(session.getAttribute("role"));

    String numParam = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    // pageNum은 숫자만 허용 (링크/스크립트에 그대로 출력되므로 반사형 XSS 방지)
    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";
    category = (category == null) ? "ALL" : category.trim().toUpperCase();
    if (!java.util.Arrays.asList("ALL", "FIX", "NORMAL").contains(category)) category = "ALL";

    if (numParam == null || !numParam.trim().matches("\\d{1,9}")) {
        response.sendRedirect("list.jsp");
        return;
    }

    int num = Integer.parseInt(numParam.trim());

    BoardDAO dao = BoardDAO.getInstance();
    boolean isBotVisit = seo.SiteUrl.isBot(request);
    if (!isBotVisit) dao.updateReadcount(num);
    BoardVO article = dao.getBoardDetail(num);

    if (article == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='list.jsp';</script>");
        return;
    }

    boolean isLiked = dao.hasUserLiked(num, sessionUserId);
    boolean isFixed = "FIX".equals(article.getNoticeType());

    boolean canManage = isAdminUser;

    CommentDAO commentDao = CommentDAO.getInstance();
    List<CommentVO> commentList = commentDao.getComments(num);

    List<BoardFileVO> fileList = BoardFileDAO.getInstance().getFiles(num);
    List<BoardFileVO> docFiles = new java.util.ArrayList<BoardFileVO>();
    // 본문은 먼저 이스케이프한 뒤 [img1] 같은 자리표시자만 태그로 바꿈 (저장형 XSS 방지)
    // 에디터(HTML)로 쓴 글은 허용된 태그만 남겨서 그대로 출력, 예전 텍스트 글은 이스케이프 후 [img1] 치환
    boolean richPost = util.RichText.isHtml(article.getContent());
    String processedContent = richPost
            ? util.RichText.sanitize(util.RichText.body(article.getContent()))
            : util.RichText.linkify(escAttr(article.getContent()));
    StringBuilder extraMedia = new StringBuilder();
    int imgIdx = 0, vidIdx = 0;
    for (BoardFileVO f : fileList) {
        if (f.isFile()) {
            docFiles.add(f);
            continue;
        }
        if (richPost && f.isImage()) continue;
        String url = request.getContextPath() + f.getWebPath();
        String tag;
        String placeholder;
        if (f.isImage()) {
            imgIdx++;
            placeholder = "[img" + imgIdx + "]";
            tag = "<img src=\"" + escAttr(url) + "\" alt=\"" + escAttr(f.getOriginalName()) + "\" class=\"post-media\">";
        } else {
            vidIdx++;
            placeholder = "[video" + vidIdx + "]";
            tag = "<video src=\"" + escAttr(url) + "\" controls class=\"post-media\"></video>";
        }
        if (processedContent.contains(placeholder)) {
            processedContent = processedContent.replace(placeholder, tag);
        } else {
            extraMedia.append(tag);
        }
    }

    String articleWriter = article.getWriterNickname() != null ? article.getWriterNickname() : article.getWriter();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= escAttr(article.getSubject()) %> - 자취의 품격</title>
    <link rel="stylesheet" href="../css/noticeboard/content.css">
    <link rel="stylesheet" href="../css/link-preview.css">
    <link rel="canonical" href="<%= escAttr(seo.SiteUrl.articleUrl(request, num, article.getCategory())) %>">
<%
    String seoDesc = seo.SiteUrl.excerpt(article.getContent(), 150);
    if (seoDesc.isEmpty()) seoDesc = article.getSubject() + " - 자취의 품격";
%>
    <meta name="description" content="<%= escAttr(seoDesc) %>">
    <meta property="og:type" content="article">
    <meta property="og:site_name" content="자취의 품격">
    <meta property="og:title" content="<%= escAttr(article.getSubject()) %> - 자취의 품격">
    <meta property="og:description" content="<%= escAttr(seoDesc) %>">
    <meta property="og:url" content="<%= escAttr(seo.SiteUrl.articleUrl(request, num, article.getCategory())) %>">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false"/>

<div class="container">
    <div class="card">
        <span class="notice-badge <%= isFixed ? "FIX" : "NORMAL" %>"><%= isFixed ? "📌 고정공지" : "📝 일반공지" %></span>
        <h1 class="post-title"><%= escAttr(article.getSubject()) %></h1>
        <div class="post-meta">
            <span>작성자: <b><%= escAttr(articleWriter) %></b></span>
            <span>작성일: <%= article.getRegDate() != null ? sdf.format(article.getRegDate()) : "" %></span>
            <span>조회수: <%= article.getReadcount() %></span>
        </div>
        <div class="post-content<%= richPost ? " rich" : "" %>"><%= processedContent %><%= extraMedia.toString() %></div>
        <div id="linkPreviews" class="link-previews" data-num="<%= num %>" data-endpoint="<%= request.getContextPath() %>/link-preview"></div>

        <% if (!docFiles.isEmpty()) { %>
        <ul class="attach-list">
            <% for (BoardFileVO f : docFiles) { %>
            <li>
                <a href="<%= escAttr(request.getContextPath() + f.getWebPath()) %>" download="<%= escAttr(f.getOriginalName()) %>">
                    📎 <%= escAttr(f.getOriginalName()) %> <span class="attach-size">(<%= formatSize(f.getFileSize()) %>)</span>
                </a>
            </li>
            <% } %>
        </ul>
        <% } %>

        <div class="btn-box">
            <!-- 상태를 바꾸는 요청이라 GET 링크가 아닌 POST 폼 + CSRF 토큰으로 전송 -->
            <form method="post" action="likePro.jsp" style="display:inline; margin:0;">
                <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                <input type="hidden" name="num" value="<%= num %>">
                <input type="hidden" name="pageNum" value="<%= pageNum %>">
                <input type="hidden" name="category" value="<%= category %>">
                <button type="submit" class="btn btn-like <%= isLiked ? "active" : "" %>">
                    <%= isLiked ? "❤️ 추천취소" : "🤍 추천하기" %> <b><%= article.getLikeCount() %></b>
                </button>
            </form>

            <div>
                <% if (canManage) { %>
                    <button class="btn" style="background:#f1f5f9;" onclick="location.href='updateForm.jsp?num=<%= num %>&pageNum=<%= pageNum %>&category=<%= category %>'">수정</button>
                    <form method="post" action="deletePro.jsp" style="display:inline; margin:0;"
                          onsubmit="return confirm('정말 삭제하시겠습니까?');">
                        <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                        <input type="hidden" name="num" value="<%= num %>">
                        <input type="hidden" name="pageNum" value="<%= pageNum %>">
                        <button type="submit" class="btn" style="background:#fee2e2; color:#dc2626;">삭제</button>
                    </form>
                <% } %>
                <button class="btn btn-list" onclick="location.href='list.jsp?pageNum=<%= pageNum %>&category=<%= category %>'">목록</button>
            </div>
        </div>
    </div>

    <div class="comment-section">
        <h3 class="comment-header">💬 댓글 <span>(<%= commentList.size() %>)</span></h3>

        <form action="commentWritePro.jsp" method="post" class="comment-form"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
            <input type="hidden" name="boardNum" value="<%= num %>">
            <input type="hidden" name="pageNum" value="<%= pageNum %>">
            <input type="hidden" name="category" value="<%= category %>">
            <textarea name="content" class="comment-textarea" placeholder="<%= sessionUserId == null ? "로그인 후 댓글 작성이 가능합니다." : "따뜻한 댓글을 남겨주세요." %>" <%= sessionUserId == null ? "disabled" : "" %> required></textarea>
            <button type="submit" class="btn-comment-submit" <%= sessionUserId == null ? "disabled" : "" %>>등록</button>
        </form>

        <ul class="comment-list">
            <% if (commentList.isEmpty()) { %>
                <li style="text-align: center; color: #94a3b8; padding: 20px 0; font-size: 14px;">첫 번째 댓글을 작성해 보세요!</li>
            <% } else {
                for (CommentVO comment : commentList) {
                    String cWriter = comment.getWriterNickname() != null ? comment.getWriterNickname() : comment.getWriter();
                    boolean canDeleteComment = sessionUserId != null
                            && (sessionUserId.equals(comment.getWriterId()) || isAdminUser);
            %>
                <li class="comment-item">
                    <div class="comment-top">
                        <span class="comment-writer"><%= escAttr(cWriter) %></span>
                        <div>
                            <span class="comment-date"><%= comment.getRegDate() != null ? sdf.format(comment.getRegDate()) : "" %></span>
                            <% if (canDeleteComment) { %>
                                <button type="button" class="btn-comment-edit" onclick="toggleCommentEdit(<%= comment.getCommentNum() %>)">수정</button>
                                <form method="post" action="commentDeletePro.jsp" style="display:inline"
                                      onsubmit="return confirm('댓글을 삭제하시겠습니까?');"><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                                    <input type="hidden" name="commentNum" value="<%= comment.getCommentNum() %>">
                                    <input type="hidden" name="boardNum" value="<%= num %>">
                                    <input type="hidden" name="pageNum" value="<%= pageNum %>">
                                    <input type="hidden" name="category" value="<%= category %>">
                                    <button type="submit" class="btn-comment-del">삭제</button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                    <div class="comment-text" id="comment-text-<%= comment.getCommentNum() %>"><%= util.RichText.linkify(escAttr(comment.getContent())) %></div>
                    <% if (canDeleteComment) { %>
                    <form method="post" action="commentUpdatePro.jsp" class="comment-edit-form" id="comment-edit-<%= comment.getCommentNum() %>" hidden><input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
                        <input type="hidden" name="commentNum" value="<%= comment.getCommentNum() %>">
                        <input type="hidden" name="boardNum" value="<%= num %>">
                        <input type="hidden" name="pageNum" value="<%= pageNum %>">
                        <input type="hidden" name="category" value="<%= category %>">
                        <textarea name="content" class="comment-textarea" maxlength="1000" required><%= escAttr(comment.getContent()) %></textarea>
                        <div class="comment-edit-actions">
                            <button type="button" class="btn-comment-cancel" onclick="toggleCommentEdit(<%= comment.getCommentNum() %>)">취소</button>
                            <button type="submit" class="btn-comment-save">저장</button>
                        </div>
                    </form>
                    <% } %>
                </li>
            <%
                }
            }
            %>
        </ul>
    </div>
</div>

<script>
    function toggleCommentEdit(id) {
        var form = document.getElementById('comment-edit-' + id);
        var text = document.getElementById('comment-text-' + id);
        var open = form.hidden;
        form.hidden = !open;
        text.hidden = open;
        if (open) form.querySelector('textarea').focus();
    }
</script>
<jsp:include page="/module/footer.jsp" flush="false"/>
<script src="../js/link-preview.js"></script>
</body>
</html>
