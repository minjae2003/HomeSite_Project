<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO, member.MemberVO, mypage.MyPageDAO, mypage.Level, mypage.ProfileDAO, mypage.ProfileVO, java.util.List, java.util.Map" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String firstChar(String s) {
        if (s == null || s.isEmpty()) return "?";
        return s.substring(0, s.offsetByCodePoints(0, 1));
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
    String nickname = member.getNickname() != null && !member.getNickname().isEmpty() ? member.getNickname() : member.getId();

    ProfileVO profile = ProfileDAO.getInstance().get(sessionUserId);
    String region = profile.getRegion() == null ? "" : profile.getRegion();
    String years = profile.getLivingYears() == null ? "" : profile.getLivingYears();
    List<String> myTags = profile.getTagList();
    String bio = profile.getBio() == null ? "" : profile.getBio();
    String imgUrl = profile.hasImage() ? request.getContextPath() + "/uploads/profile/" + profile.getProfileImg() : "";

    // 미리보기 등급 (마이페이지와 같은 계산)
    MyPageDAO my = MyPageDAO.getInstance();
    Level level = new Level(my.getPostCount(sessionUserId), my.getCommentCount(sessionUserId), my.getReceivedLikeCount(sessionUserId));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>프로필 편집 — 자취의 품격</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/index.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/profile.css">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="wrap">
  <div class="pf-head">
    <div class="breadcrumb"><a href="index.jsp">마이페이지</a> &gt; <b>프로필 편집</b></div>
    <h1 class="page-title">프로필 편집</h1>
  </div>

  <form method="post" action="${pageContext.request.contextPath}/mypage/profileSave" enctype="multipart/form-data"
        id="profileForm" onsubmit="return checkProfile(this);">
  <input type="hidden" name="removePhoto" id="removePhoto" value="N">

  <div class="main-grid pf-grid">
    <main>

      <div class="pf-card">
        <div class="pf-card-head">
          <h3>기본 정보</h3>
          <p>다른 회원들에게 공개되는 프로필 정보예요.</p>
        </div>
        <div class="pf-card-body">

          <!-- 프로필 사진 -->
          <div class="field">
            <label>프로필 사진 <span class="hint">jpg · png · gif · webp, 5MB 이하</span></label>
            <div class="photo-row">
              <div class="photo-preview avatar-box" id="photoPreview">
                <% if (profile.hasImage()) { %><img src="<%= esc(imgUrl) %>" alt="프로필 사진"><% } else { %><%= esc(firstChar(nickname)) %><% } %>
              </div>
              <div class="photo-btns">
                <input type="file" name="photo" id="photoInput" accept="image/jpeg,image/png,image/gif,image/webp" hidden>
                <button type="button" class="btn btn-outline pf-btn" onclick="document.getElementById('photoInput').click();">사진 변경</button>
                <button type="button" class="btn btn-outline pf-btn" onclick="resetPhoto();">기본 이미지로</button>
              </div>
            </div>
          </div>

          <!-- 닉네임 -->
          <div class="field">
            <label for="nickname">닉네임</label>
            <input type="text" id="nickname" name="nickname" maxlength="50" value="<%= esc(nickname) %>" required>
          </div>

          <!-- 한줄 소개 -->
          <div class="field">
            <label for="bio">한줄 소개 <span class="hint">최대 <%= ProfileDAO.BIO_MAX %>자</span></label>
            <textarea id="bio" name="bio" maxlength="<%= ProfileDAO.BIO_MAX %>" placeholder="나를 한 줄로 소개해 보세요"><%= esc(bio) %></textarea>
            <div class="char-count"><span id="bioCount"><%= bio.length() %></span> / <%= ProfileDAO.BIO_MAX %></div>
          </div>

          <!-- 거주 지역 / 자취 연차 (기본값: 설정 안 함) -->
          <div class="field-row">
            <div class="field">
              <label for="region">거주 지역</label>
              <select id="region" name="region">
                <option value="" <%= region.isEmpty() ? "selected" : "" %>>설정 안 함</option>
                <% for (Map.Entry<String, List<String>> g : ProfileDAO.REGIONS.entrySet()) { %>
                <optgroup label="<%= g.getKey() %>">
                  <% for (String r : g.getValue()) { %>
                  <option value="<%= r %>" <%= r.equals(region) ? "selected" : "" %>><%= ProfileDAO.shortRegion(r) %></option>
                  <% } %>
                </optgroup>
                <% } %>
              </select>
            </div>
            <div class="field">
              <label for="livingYears">자취 연차</label>
              <select id="livingYears" name="livingYears">
                <option value="" <%= years.isEmpty() ? "selected" : "" %>>설정 안 함</option>
                <% for (String y : ProfileDAO.YEARS) { %>
                <option value="<%= y %>" <%= y.equals(years) ? "selected" : "" %>><%= y %></option>
                <% } %>
              </select>
            </div>
          </div>

          <!-- 관심 태그 -->
          <div class="field">
            <label>관심 태그 <span class="hint">최대 <%= ProfileDAO.TAG_MAX %>개 선택</span></label>
            <div class="tag-select">
              <% for (String t : ProfileDAO.TAGS) { %>
              <label class="tag-choice">
                <input type="checkbox" name="tags" value="<%= t %>" <%= myTags.contains(t) ? "checked" : "" %>>
                <span>#<%= t %></span>
              </label>
              <% } %>
            </div>
          </div>

        </div>
      </div>

      <div class="form-actions pf-actions">
        <a href="index.jsp" class="btn btn-outline pf-btn">취소</a>
        <button type="submit" class="btn btn-primary pf-btn">변경사항 저장</button>
      </div>
    </main>

    <aside>
      <div class="side-block">
        <p class="side-title">미리보기</p>
        <div class="preview-card">
          <div class="preview-avatar avatar-box" id="previewAvatar">
            <% if (profile.hasImage()) { %><img src="<%= esc(imgUrl) %>" alt=""><% } else { %><%= esc(firstChar(nickname)) %><% } %>
          </div>
          <div class="preview-name" id="previewName"><%= esc(nickname) %></div>
          <span class="preview-badge">Lv.<%= level.getLevel() %> · <%= level.getName() %></span>
          <p class="preview-meta" id="previewMeta"></p>
          <p class="preview-bio" id="previewBio"><%= esc(bio) %></p>
        </div>
      </div>

      <div class="side-block">
        <p class="side-title">프로필 작성 팁</p>
        <ul class="tips-list">
          <li>닉네임은 헤더와 새로 쓰는 글·댓글에 표시돼요</li>
          <li>거주 지역과 자취 연차는 설정하지 않아도 괜찮아요</li>
          <li>한줄 소개와 관심 태그는 마이페이지 프로필에 보여요</li>
        </ul>
      </div>
    </aside>
  </div>
  </form>
</div>

<script>
(function () {
  var form = document.getElementById('profileForm');
  var nick = document.getElementById('nickname');
  var bio = document.getElementById('bio');
  var region = document.getElementById('region');
  var years = document.getElementById('livingYears');
  var photoInput = document.getElementById('photoInput');
  var removePhoto = document.getElementById('removePhoto');
  var boxes = [document.getElementById('photoPreview'), document.getElementById('previewAvatar')];
  var TAG_MAX = <%= ProfileDAO.TAG_MAX %>;

  function firstChar(s) { s = (s || '').trim(); return s ? Array.from(s)[0] : '?'; }

  // 아바타 두 곳(사진 칸, 미리보기)을 같이 바꿈
  function setAvatar(src) {
    boxes.forEach(function (box) {
      box.textContent = '';
      if (src) {
        var img = document.createElement('img');
        img.src = src; img.alt = '';
        box.appendChild(img);
      } else {
        box.textContent = firstChar(nick.value);
      }
    });
  }

  // 사진 선택 → 바로 미리보기
  photoInput.addEventListener('change', function () {
    var f = photoInput.files[0];
    if (!f) return;
    if (!/^image\/(jpeg|png|gif|webp)$/.test(f.type)) {
      alert('jpg, png, gif, webp 이미지만 올릴 수 있어요.');
      photoInput.value = ''; return;
    }
    if (f.size > 5 * 1024 * 1024) {
      alert('프로필 사진은 5MB 이하만 올릴 수 있어요.');
      photoInput.value = ''; return;
    }
    removePhoto.value = 'N';
    var reader = new FileReader();
    reader.onload = function (e) { setAvatar(e.target.result); };
    reader.readAsDataURL(f);
  });

  // 기본 이미지로 (저장해야 반영)
  window.resetPhoto = function () {
    photoInput.value = '';
    removePhoto.value = 'Y';
    setAvatar(null);
  };

  // 한줄 소개 글자 수 + 미리보기
  function updateText() {
    document.getElementById('bioCount').textContent = bio.value.length;
    document.getElementById('previewName').textContent = nick.value.trim() || '닉네임';
    document.getElementById('previewBio').textContent = bio.value;
    var hasImg = boxes[0].querySelector('img');
    if (!hasImg) boxes.forEach(function (b) { b.textContent = firstChar(nick.value); });

    var meta = [];
    if (years.value) meta.push('자취 ' + years.value);
    if (region.value) meta.push(region.value.split(' ').pop() === '지역' ? region.value : region.value.split(' ').pop());
    document.getElementById('previewMeta').textContent = meta.join(' · ');
  }
  [nick, bio].forEach(function (el) { el.addEventListener('input', updateText); });
  [region, years].forEach(function (el) { el.addEventListener('change', updateText); });
  updateText();

  // 관심 태그 최대 개수 제한
  var tagBoxes = form.querySelectorAll('input[name=tags]');
  tagBoxes.forEach(function (cb) {
    cb.addEventListener('change', function () {
      var checked = form.querySelectorAll('input[name=tags]:checked').length;
      if (checked > TAG_MAX) {
        cb.checked = false;
        alert('관심 태그는 최대 ' + TAG_MAX + '개까지 선택할 수 있어요.');
      }
    });
  });

  window.checkProfile = function (f) {
    if (!f.nickname.value.trim()) { alert('닉네임을 입력해 주세요.'); f.nickname.focus(); return false; }
    return true;
  };
})();
</script>

</body>
</html>