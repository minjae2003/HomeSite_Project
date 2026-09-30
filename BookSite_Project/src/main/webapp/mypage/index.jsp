<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, mypage.MyPageDAO, mypage.Level, board.BoardVO, java.util.List, java.util.Map,mypage.ProfileDAO, mypage.ProfileVO, java.text.SimpleDateFormat" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String catName(String c) {
        if ("TIP".equals(c)) return "꿀팁";
        if ("QNA".equals(c)) return "질문";
        if ("RECIPE".equals(c)) return "레시피";
        if ("NOTICE".equals(c)) return "공지";
        return "일상";
    }
    private String catIcon(String c) {
        if ("TIP".equals(c)) return "💡";
        if ("QNA".equals(c)) return "❓";
        if ("RECIPE".equals(c)) return "🍳";
        if ("NOTICE".equals(c)) return "📢";
        return "💬";
    }
    private int count(Map<String, Integer> m, String key) {
        Integer v = m.get(key);
        return v == null ? 0 : v;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // 로그인 확인
    String sessionUserId = (String) session.getAttribute("id");
    if (sessionUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    MemberVO member = MemberDAO.getInstance().getMember(sessionUserId);
    if (member == null) {
        out.println("<script>alert('회원 정보를 찾을 수 없습니다.'); location.href='../main/index.jsp';</script>");
        return;
    }
    String nickname = member.getNickname() != null && !member.getNickname().isEmpty() ? member.getNickname() : member.getId();
    boolean isAdmin = "ADMIN".equals(member.getRole());
    // 공개 프로필 (사진 / 한줄 소개 / 지역 / 연차 / 관심 태그)
    ProfileVO profile = ProfileDAO.getInstance().get(sessionUserId);
    // ── 활동 통계 ──
    MyPageDAO dao = MyPageDAO.getInstance();
    int postCount = dao.getPostCount(sessionUserId);
    int commentCount = dao.getCommentCount(sessionUserId);
    int receivedLikes = dao.getReceivedLikeCount(sessionUserId);
    int likedCount = dao.getLikedCount(sessionUserId);

    Level level = new Level(postCount, commentCount, receivedLikes);

    // ── 뱃지 (활동 기록으로 자동 획득) ──
    Map<String, Integer> byCat = dao.getPostCountByCategory(sessionUserId);
    int maxLike = dao.getMaxLike(sessionUserId);
    String[][] badges = {
        // {아이콘, 이름, 획득조건 설명}
        {"✍️", "첫 글", "글을 1개 이상 작성"},
        {"💡", "정보통", "자취꿀팁 글 3개 이상"},
        {"🍳", "자취요리사", "요리레시피 글 1개 이상"},
        {"🏆", "베스트글", "추천 10개 이상 받은 글"}
    };
    boolean[] earned = {
        postCount >= 1,
        count(byCat, "TIP") >= 3,
        count(byCat, "RECIPE") >= 1,
        maxLike >= 10
    };

    // ── 체크리스트 (계정에 저장된 진행률) ──
    int[] checklist = dao.getChecklistProgress(sessionUserId);

    // ── 탭 + 페이징 ──
    String tab = request.getParameter("tab");
    if (!MyPageDAO.TAB_COMMENTS.equals(tab) && !MyPageDAO.TAB_LIKES.equals(tab)) tab = MyPageDAO.TAB_POSTS;

    int pageSize = 8;
    int currentPage = 1;
    String pageNumStr = request.getParameter("pageNum");
    if (pageNumStr != null && pageNumStr.matches("\\d{1,6}")) currentPage = Math.max(1, Integer.parseInt(pageNumStr));

    int tabTotal = dao.getTabCount(tab, sessionUserId);
    int pageCount = Math.max(1, (tabTotal + pageSize - 1) / pageSize);
    if (currentPage > pageCount) currentPage = pageCount;
    List<BoardVO> rows = dao.getTabList(tab, sessionUserId, (currentPage - 1) * pageSize, pageSize);

    int commentedPosts = dao.getCommentedPostCount(sessionUserId);

    SimpleDateFormat joinFmt = new SimpleDateFormat("yyyy.MM.dd");
    SimpleDateFormat rowFmt = new SimpleDateFormat("MM.dd");
    String emptyMsg = MyPageDAO.TAB_COMMENTS.equals(tab) ? "아직 댓글을 단 글이 없어요."
                    : MyPageDAO.TAB_LIKES.equals(tab) ? "아직 추천한 글이 없어요."
                    : "아직 작성한 글이 없어요. 첫 글을 남겨보세요!";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>마이페이지 — 자취의 품격</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/index.css">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="wrap">

    <!-- 프로필 -->
  <div class="profile-card">
    <div class="profile-avatar">
      <% if (profile.hasImage()) { %>
        <img src="${pageContext.request.contextPath}/uploads/profile/<%= esc(profile.getProfileImg()) %>" alt="프로필 사진">
      <% } else { %><%= esc(nickname.substring(0, nickname.offsetByCodePoints(0, 1))) %><% } %>
    </div>
    <div class="profile-info">
      <div class="profile-name-row">
        <span class="profile-name"><%= esc(nickname) %></span>
        <span class="grade-badge">Lv.<%= level.getLevel() %> · <%= level.getName() %></span>
        <% if (isAdmin) { %><span class="role-badge">관리자</span><% } %>
      </div>
      <div class="profile-sub">
        @<%= esc(member.getId()) %>
        <% if (profile.getLivingYears() != null) { %> · 자취 <%= esc(profile.getLivingYears()) %><% } %>
        <% if (member.getRegDate() != null) { %> · <%= joinFmt.format(member.getRegDate()) %> 가입<% } %>
        <% if (profile.getRegion() != null) { %> · <%= esc(profile.getRegion()) %><% } %>
        · 활동점수 <%= level.getPoint() %>P
      </div>
      <% if (profile.getBio() != null) { %>
      <div class="profile-bio"><%= esc(profile.getBio()) %></div>
      <% } %>
      <% if (!profile.getTagList().isEmpty()) { %>
      <div class="profile-tags">
        <% for (String t : profile.getTagList()) { %><span class="profile-tag">#<%= esc(t) %></span><% } %>
      </div>
      <% } %>
    </div>
    <div class="profile-actions">
      <a href="profileEdit.jsp" class="btn btn-outline">프로필 편집</a>
      <a href="../freeboard/writeForm.jsp" class="btn btn-primary">글쓰기</a>
    </div>
  </div>

  <!-- 활동 통계 -->
  <div class="stat-grid">
    <div class="stat-cell"><div class="num"><%= postCount %></div><div class="label">작성글</div></div>
    <div class="stat-cell"><div class="num"><%= commentCount %></div><div class="label">작성댓글</div></div>
    <div class="stat-cell"><div class="num"><%= receivedLikes %></div><div class="label">받은 추천</div></div>
    <div class="stat-cell"><div class="num"><%= likedCount %></div><div class="label">추천한 글</div></div>
  </div>

  <div class="main-grid">
    <main>
      <div class="tabs">
        <a href="index.jsp?tab=posts" class="tab <%= MyPageDAO.TAB_POSTS.equals(tab) ? "active" : "" %>">내가 쓴 글 <span class="tab-count"><%= postCount %></span></a>
        <a href="index.jsp?tab=comments" class="tab <%= MyPageDAO.TAB_COMMENTS.equals(tab) ? "active" : "" %>">댓글 단 글 <span class="tab-count"><%= commentedPosts %></span></a>
        <a href="index.jsp?tab=likes" class="tab <%= MyPageDAO.TAB_LIKES.equals(tab) ? "active" : "" %>">추천한 글 <span class="tab-count"><%= likedCount %></span></a>
      </div>

      <div class="post-list">
      <% if (rows.isEmpty()) { %>
        <div class="list-empty"><%= emptyMsg %></div>
      <% } else {
           for (BoardVO row : rows) {
               String cat = row.getCategory();
               String folder = "NOTICE".equals(cat) ? "noticeboard" : "freeboard";
      %>
        <a class="post-row" href="../<%= folder %>/content.jsp?num=<%= row.getNum() %>">
          <span class="post-icon"><%= catIcon(cat) %></span>
          <span class="post-cat-label"><%= catName(cat) %></span>
          <span class="post-title"><%= esc(row.getSubject()) %><% if (row.getCommentCount() > 0) { %><span class="cmt">[<%= row.getCommentCount() %>]</span><% } %></span>
          <span class="post-date"><%= row.getRegDate() != null ? rowFmt.format(row.getRegDate()) : "" %></span>
          <span class="post-stats">조회 <b><%= row.getReadcount() %></b> ｜ 추천 <b><%= row.getLikeCount() %></b></span>
        </a>
      <%   }
         } %>
      </div>

      <% if (pageCount > 1) {
           int pageBlock = 5;
           int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
           int endPage = Math.min(startPage + pageBlock - 1, pageCount);
      %>
      <div class="pagination">
        <% if (startPage > 1) { %>
        <a class="page-num" href="index.jsp?tab=<%= tab %>&pageNum=<%= startPage - 1 %>">‹</a>
        <% } %>
        <% for (int i = startPage; i <= endPage; i++) { %>
        <a class="page-num <%= i == currentPage ? "active" : "" %>" href="index.jsp?tab=<%= tab %>&pageNum=<%= i %>"><%= i %></a>
        <% } %>
        <% if (endPage < pageCount) { %>
        <a class="page-num" href="index.jsp?tab=<%= tab %>&pageNum=<%= endPage + 1 %>">›</a>
        <% } %>
      </div>
      <% } %>
    </main>

    <aside>
      <!-- 등급 -->
      <div class="side-block">
        <p class="side-title"><%= level.isMax() ? "최고 등급 달성!" : "다음 등급까지" %></p>
        <div class="progress-track"><div class="progress-fill" style="width:<%= level.getPercent() %>%"></div></div>
        <div class="progress-label">
          <% if (level.isMax()) { %>
            <b>Lv.<%= level.getLevel() %> <%= level.getName() %></b> 등급이에요 🎉
          <% } else { %>
            Lv.<%= level.getNextLevel() %> <%= level.getNextName() %>까지 <b><%= level.getRemain() %>P</b> 남았어요
          <% } %>
        </div>
        <p class="side-desc" style="margin:10px 0 0;">글 10P · 댓글 2P · 받은 추천 5P</p>
      </div>

      <!-- 뱃지 -->
      <div class="side-block">
        <p class="side-title">획득 뱃지</p>
        <div class="badge-grid">
        <% for (int i = 0; i < badges.length; i++) { %>
          <div class="badge-item" title="<%= badges[i][2] %><%= earned[i] ? " (획득)" : "" %>">
            <div class="badge-circle <%= earned[i] ? "" : "locked" %>"><%= badges[i][0] %></div>
            <div class="badge-name"><%= badges[i][1] %></div>
          </div>
        <% } %>
        </div>
      </div>

      <!-- 체크리스트 -->
      <div class="side-block">
        <p class="side-title">자취 시작 체크리스트</p>
        <% if (checklist != null && checklist[1] > 0) {
             int pct = (int) Math.round(checklist[0] * 100.0 / checklist[1]);
        %>
          <div class="progress-track"><div class="progress-fill" style="width:<%= pct %>%"></div></div>
          <div class="progress-label"><%= checklist[0] %> / <%= checklist[1] %>개 완료 <b>(<%= pct %>%)</b></div>
          <a href="../main/checklist.jsp" class="btn btn-outline btn-block" style="margin-top:12px;">이어서 체크하기</a>
        <% } else { %>
          <p class="side-desc">아직 계정에 저장된 체크리스트가 없어요. 이사 준비부터 생활 적응까지 순서대로 체크해보세요.</p>
          <a href="../main/checklist.jsp" class="btn btn-primary btn-block">체크리스트 시작하기</a>
        <% } %>
      </div>

      <!-- 계정 관리 -->
      <div class="side-block">
        <p class="side-title">계정 관리</p>
        <p class="side-desc">로그인 정보, 알림 설정, 회원 탈퇴 등을 관리할 수 있어요.</p>
<a href="account.jsp" class="btn btn-outline btn-block">계정 관리 바로가기</a>
      </div>
    </aside>
  </div>
</div>

</body>
</html>
