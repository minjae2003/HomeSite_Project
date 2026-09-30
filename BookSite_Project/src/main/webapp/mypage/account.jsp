<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, notification.NotificationDAO, java.text.SimpleDateFormat" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

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
    boolean isAdmin = "ADMIN".equals(member.getRole());

    SimpleDateFormat fmt = new SimpleDateFormat("yyyy.MM.dd");
    String pwChanged = member.getPwChangedAt() != null ? fmt.format(member.getPwChangedAt()) : "변경 기록 없음";
    String infoChanged = member.getInfoChangedAt() != null ? fmt.format(member.getInfoChangedAt()) : "변경 기록 없음";

    // 알림 수신 설정 {댓글, 추천, 공지}
    boolean[] settings = NotificationDAO.getInstance().getSettings(sessionUserId);
    String[][] settingRows = {
        {"COMMENT", "댓글 알림", "내 글에 댓글이 달리면 알려드려요"},
        {"LIKE", "추천 알림", "내 글이 추천을 받으면 알려드려요"},
        {"NOTICE", "공지사항 알림", "새 공지사항이 등록되면 알려드려요"}
    };
    String selfUrl = request.getContextPath() + "/mypage/account.jsp";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>계정 관리 — 자취의 품격</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/index.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/account.css">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="wrap">
  <div class="acct-head">
    <div class="breadcrumb"><a href="index.jsp">마이페이지</a> &gt; <b>계정 관리</b></div>
    <h1 class="page-title">계정 관리</h1>
  </div>

  <div class="main-grid acct-grid">
    <main>

      <!-- 로그인 정보 -->
      <div class="acct-card" id="login-info">
        <div class="acct-card-head">
          <h3>로그인 정보</h3>
          <p>아이디, 이메일과 비밀번호 등 로그인에 사용하는 정보예요.</p>
        </div>
        <div class="acct-card-body">
          <div class="field">
            <label>아이디</label>
            <input type="text" value="<%= esc(member.getId()) %>" readonly>
          </div>
          <div class="field">
            <label>이메일</label>
            <input type="email" value="<%= esc(member.getEmail()) %>" readonly>
          </div>
          
          <div class="divider"></div>
          <div class="row-between">
            <div>
              <div class="toggle-label">회원정보 수정</div>
              <span class="row-sub">닉네임 · 이름 · 이메일 / 마지막 변경일 <b><%= infoChanged %></b></span>
            </div>
            <a href="../member/memberupdateForm.jsp" class="btn btn-outline acct-btn">정보 변경</a>
          </div>
        </div>
      </div>

      <!-- 알림 설정 (스위치를 누르면 바로 저장) -->
      <div class="acct-card" id="notiSetting">
        <div class="acct-card-head">
          <h3>알림 설정</h3>
          <p>끈 알림은 새로 생기지 않아요. 이미 받은 알림은 그대로 남아요.</p>
        </div>
        <div class="acct-card-body">
          <% for (int i = 0; i < settingRows.length; i++) { %>
          <form method="post" action="notiSetting.jsp" class="toggle-row">
            <div>
              <div class="toggle-label"><%= settingRows[i][1] %></div>
              <div class="toggle-desc"><%= settingRows[i][2] %></div>
            </div>
            <input type="hidden" name="type" value="<%= settingRows[i][0] %>">
            <input type="hidden" name="on" value="<%= settings[i] ? "N" : "Y" %>">
            <input type="hidden" name="returnUrl" value="<%= esc(selfUrl) %>">
            <button type="submit" class="switch <%= settings[i] ? "on" : "" %>"
                    aria-label="<%= settingRows[i][1] %> <%= settings[i] ? "끄기" : "켜기" %>"></button>
          </form>
          <% } %>
        </div>
      </div>

      <!-- 위험 구역 -->
      <div class="acct-card danger-zone" id="danger-zone">
        <div class="acct-card-head">
          <h3>위험 구역</h3>
          <p>아래 작업은 되돌릴 수 없으니 신중하게 진행해주세요.</p>
        </div>
        <div class="acct-card-body">
          <div class="row-between">
            <div>
              <div class="toggle-label">로그아웃</div>
              <div class="toggle-desc">지금 사용 중인 기기에서 로그아웃해요</div>
            </div>
            <a href="../member/LogoutPro.jsp" class="btn btn-outline acct-btn">로그아웃</a>
          </div>
          <div class="divider"></div>
          <% if (isAdmin) { %>
          <div>
            <div class="toggle-label" style="color:var(--red);">회원 탈퇴</div>
            <div class="toggle-desc">관리자 계정은 탈퇴할 수 없어요.</div>
          </div>
          <% } else { %>
          <form method="post" action="withdrawPro.jsp"
                onsubmit="return confirm('정말 탈퇴하시겠어요?\n작성한 글과 댓글이 모두 삭제되며 복구할 수 없어요.');">
            <div class="row-between">
              <div>
                <div class="toggle-label" style="color:var(--red);">회원 탈퇴</div>
                <div class="toggle-desc">작성한 글과 댓글이 모두 삭제되며 복구할 수 없어요</div>
              </div>
              <div class="withdraw-actions">
                <input type="password" name="password" class="withdraw-pass" placeholder="현재 비밀번호" required autocomplete="current-password">
                <button type="submit" class="btn btn-danger-outline acct-btn">탈퇴하기</button>
              </div>
            </div>
          </form>
          <% } %>
        </div>
      </div>

    </main>

    <aside>
      <div class="side-block acct-side">
        <p class="side-title">바로가기</p>
        <ul class="settings-list">
          <li><a href="#login-info"><span class="dot"></span>로그인 정보</a></li>
          <li><a href="#notiSetting"><span class="dot"></span>알림 설정</a></li>
          <li><a href="#danger-zone"><span class="dot"></span>위험 구역</a></li>
        </ul>
      </div>

      <div class="side-block">
        <p class="side-title">안내</p>
        <div class="info-box">
          닉네임, 이름, 이메일처럼 다른 회원에게 보이거나 연락에 쓰이는 정보는 <b>정보 변경</b>에서 수정할 수 있어요.
          알림은 <a href="notifications.jsp"><b>전체 알림</b></a>에서 모아볼 수 있어요.
        </div>
      </div>
    </aside>
  </div>
</div>

<script>
  // 바로가기: 부드럽게 스크롤 + 현재 항목 강조
  (function () {
    var links = document.querySelectorAll('.settings-list a');
    function setActive(hash) {
      links.forEach(function (a) { a.parentNode.classList.toggle('active', a.getAttribute('href') === hash); });
    }
    links.forEach(function (a) {
      a.addEventListener('click', function (e) {
        var target = document.querySelector(a.getAttribute('href'));
        if (!target) return;
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth' });
        history.replaceState(null, '', a.getAttribute('href'));
        setActive(a.getAttribute('href'));
      });
    });
    setActive(location.hash || '#login-info');
  })();
</script>

</body>
</html>