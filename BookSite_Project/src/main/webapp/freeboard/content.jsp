<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO" %>
<%@ page import="board.BoardVO" %>
<%@ page import="reply.ReplyDAO" %>
<%@ page import="reply.ReplyVO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    int num = Integer.parseInt(request.getParameter("num"));
    String pageNum = request.getParameter("pageNum");
    String category = request.getParameter("category");

    BoardDAO dao = BoardDAO.getInstance();
    dao.updateReadcount(num); // 조회수 증가
    BoardVO board = dao.getBoardDetail(num);

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm");
    
    // 세션 로그인 회원 정보 및 권한 체크
    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");
    
    boolean isOwnerOrAdmin = sessionUserId != null && (sessionUserId.equals(board.getWriterId()) || "ADMIN".equals(sessionRole));
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= board.getSubject() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/board.css">
</head>
<body>

    <jsp:include page="/module/header.jsp" flush="false"/>

    <div class="container">
        <main class="main-content">
            <div class="post-detail">
                <h2><%= board.getSubject() %></h2>
                <div class="post-info">
                    <span>작성자: <b><%= board.getWriterNickname() %></b></span> | 
                    <span>작성일: <%= sdf.format(board.getRegDate()) %></span> | 
                    <span>조회: <%= board.getReadcount() %></span> | 
                    <span>추천: <%= board.getLikeCount() %></span>
                </div>
                <hr>
                <div class="post-content">
                    <%= board.getContent().replace("\n", "<br>") %>
                </div>
                
                <!-- 추천 버튼 -->
                <div class="like-box" style="text-align: center; margin: 30px 0;">
                    <button type="button" onclick="location.href='likePro.jsp?num=<%= board.getNum() %>&pageNum=<%= pageNum %>'" class="btn-like">
                        👍 추천 (<%= board.getLikeCount() %>)
                    </button>
                </div>

                <!-- 권한 기반 버튼 조작 -->
                <div class="post-buttons">
                    <button onclick="location.href='list.jsp?pageNum=<%= pageNum %>&category=<%= category %>'">목록보기</button>
                    
                    <% if (isOwnerOrAdmin) { %>
                        <button onclick="location.href='updateForm.jsp?num=<%= board.getNum() %>&pageNum=<%= pageNum %>'">수정</button>
                        <button onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='deletePro.jsp?num=<%= board.getNum() %>'">삭제</button>
                    <% } %>
                </div>
            </div>

            <!-- 댓글 영역 -->
            <div class="reply-section" style="margin-top: 40px;">
                <h3>💬 댓글 목록</h3>
                
                <!-- 댓글 작성 폼 (로그인 사용자 전용) -->
                <% if (sessionUserId != null) { %>
                    <form action="replyWritePro.jsp" method="post" class="reply-form">
                        <input type="hidden" name="boardNum" value="<%= board.getNum() %>">
                        <input type="hidden" name="pageNum" value="<%= pageNum %>">
                        <textarea name="content" placeholder="댓글을 남겨보세요." required style="width: 100%; height: 70px;"></textarea>
                        <button type="submit">댓글 등록</button>
                    </form>
                <% } else { %>
                    <p class="text-muted">댓글을 작성하려면 <a href="${pageContext.request.contextPath}/member/loginForm.jsp">로그인</a>이 필요합니다.</p>
                <% } %>
            </div>
        </main>
    </div>

    <jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>