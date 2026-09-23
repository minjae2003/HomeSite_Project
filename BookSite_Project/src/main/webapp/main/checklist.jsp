<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="checklist.ChecklistDAO" %>
<%!
    // HTML 특수문자 이스케이프
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // ── 체크리스트 데이터 ─────────────────────────────
    // 각 카테고리: {아이콘, 제목, 사이드바 짧은이름}
    // 각 항목: {라벨, 설명} (설명이 없으면 null)
    String[][] catInfo = {
        {"📋", "이사 전 확인할 것", "이사 전 확인"},
        {"🧾", "행정 처리", "행정 처리"},
        {"🛏️", "생필품 준비", "생필품 준비"},
        {"🔒", "안전 & 보안", "안전 & 보안"},
        {"🌱", "자취 생활 적응", "생활 적응"}
    };

    String[][][] catItems = {
        { // 이사 전 확인할 것
            {"등기부등본 확인하기", "근저당, 소유자 일치 여부를 계약 직전에 다시 한 번 확인하세요"},
            {"계약서 특약사항 꼼꼼히 읽기", "수리 비용 부담 주체, 원상복구 범위를 확인하세요"},
            {"관리비 항목 확인", "고정 관리비에 어떤 항목이 포함되는지 미리 물어보세요"},
            {"주변 시세 비교하기", null},
            {"이사 날짜 및 사다리차 예약", null}
        },
        { // 행정 처리
            {"전입신고 하기", "전입일로부터 14일 이내, 정부24에서 온라인으로도 가능해요"},
            {"확정일자 받기", "보증금을 지키기 위한 필수 절차예요"},
            {"전기·가스·수도 명의 변경", null},
            {"인터넷 설치 신청", null},
            {"우편물 주소 이전 신청", null}
        },
        { // 생필품 준비
            {"침구류 (이불, 베개)", null},
            {"기본 주방용품 (냄비, 프라이팬, 수저)", null},
            {"욕실용품 (수건, 세면도구)", null},
            {"청소용품 (청소기 또는 빗자루, 세제)", null},
            {"쓰레기통 & 종량제 봉투", null},
            {"커튼 또는 블라인드", null},
            {"공구세트 (드라이버, 망치 등)", null}
        },
        { // 안전 & 보안
            {"현관 보조 잠금장치 설치", null},
            {"화재감지기 작동 확인", null},
            {"비상 연락처 저장 (집주인, 관리사무소, 가까운 경찰서)", null},
            {"소화기 비치", null}
        },
        { // 자취 생활 적응
            {"한 달 생활비 예산 짜기", null},
            {"동네 분리수거 요일·규칙 확인하기", null},
            {"이웃 및 관리사무소에 인사하기", null}
        }
    };

    int totalItems = 0;
    for (String[][] items : catItems) totalItems += items.length;

    // ── 로그인 사용자 & 계정에 저장된 체크 상태 불러오기 ──────
    Object loginObj = session.getAttribute(ChecklistDAO.SESSION_USER_KEY);
    String loginId = (loginObj == null) ? null : loginObj.toString();
    boolean isLogin = (loginId != null && !loginId.isEmpty());

    Set<String> savedKeys = null;          // null = 저장 기록 없음
    boolean loadError = false;
    if (isLogin) {
        try {
            savedKeys = new ChecklistDAO().loadKeys(loginId);
        } catch (Exception e) {
            e.printStackTrace();
            loadError = true;
        }
    }

    // JS로 넘길 JSON 배열 (키는 DAO에서 형식 검증을 거친 값만 들어옴)
    String savedJson = "null";
    if (savedKeys != null) {
        StringBuilder sb = new StringBuilder("[");
        for (String k : savedKeys) {
            if (sb.length() > 1) sb.append(',');
            sb.append('"').append(k).append('"');
        }
        savedJson = sb.append(']').toString();
    }

    // 브라우저(localStorage) 저장 공간을 계정별로 분리하기 위한 접미사
    // (URL 인코딩 → 영문/숫자/%만 남아 JS 문자열에 넣어도 안전)
    String storageSuffix = isLogin
        ? "u_" + java.net.URLEncoder.encode(loginId, "UTF-8")
        : "guest";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>자취 시작 체크리스트 — 자취의 품격</title>
<link rel="stylesheet" href="../css/main/checklist.css">
</head>
<body>

<jsp:include page="../module/header.jsp" flush="false" />

<div class="wrap">
  <div class="breadcrumb">홈 &gt; <b>자취 시작 체크리스트</b></div>
  <h1 class="page-title">자취 시작 체크리스트</h1>
  <p class="page-sub">처음 자취를 준비한다면 이 순서대로 하나씩 체크해보세요. 체크한 내용은 이 브라우저에 자동으로 남고, 로그인 후 '내 계정에 저장하기'를 누르면 어디서든 불러올 수 있어요.</p>

  <div class="progress-hero">
    <div class="progress-hero-text">
      <div class="big" id="heroText">0 / <%= totalItems %>개 완료했어요</div>
      <div class="small">꾸준히 체크하면서 자취 준비를 끝내보세요 🏠</div>
    </div>
    <div class="progress-ring-wrap">
      <div class="progress-ring">
        <svg width="84" height="84" viewBox="0 0 84 84">
          <circle cx="42" cy="42" r="36" fill="none" stroke="rgba(255,255,255,.3)" stroke-width="8"/>
          <circle id="ringFill" cx="42" cy="42" r="36" fill="none" stroke="#fff" stroke-width="8"
            stroke-linecap="round" stroke-dasharray="226.19" stroke-dashoffset="226.19"/>
        </svg>
        <div class="progress-ring-label" id="ringLabel">0%</div>
      </div>
    </div>
  </div>

  <div class="main-grid">
    <main id="checklistMain">
<%
    for (int ci = 0; ci < catInfo.length; ci++) {
        String[][] items = catItems[ci];
%>
      <div class="cat-card">
        <div class="cat-head">
          <div class="cat-icon"><%= catInfo[ci][0] %></div>
          <div class="cat-title"><%= esc(catInfo[ci][1]) %></div>
          <div class="cat-count"><b>0</b>/<%= items.length %></div>
        </div>
<%
        for (int ii = 0; ii < items.length; ii++) {
            String label = items[ii][0];
            String desc  = items[ii][1];
%>
        <label class="check-item">
          <input type="checkbox" data-key="c<%= ci %>_<%= ii %>">
          <div class="check-text">
            <div class="check-label"><%= esc(label) %></div>
<%          if (desc != null && !desc.isEmpty()) { %>
            <div class="check-desc"><%= esc(desc) %></div>
<%          } %>
          </div>
        </label>
<%
        }
%>
      </div>
<%
    }
%>
    </main>

    <aside>
      <div class="side-block">
        <p class="side-title">카테고리별 진행률</p>
<%
    for (int ci = 0; ci < catInfo.length; ci++) {
%>
        <div class="mini-progress-row" data-cat-progress="<%= ci %>">
          <span class="label"><%= esc(catInfo[ci][2]) %></span>
          <div class="track"><div class="fill" style="width:0%"></div></div>
          <span class="pct">0%</span>
        </div>
<%
    }
%>
      </div>
      <div class="side-block">
        <p class="side-title">체크리스트 활용 팁</p>
        <ul class="tips-list">
          <li>이사 2주 전부터 하나씩 체크하면 급하게 처리할 일이 줄어요</li>
          <li>전입신고와 확정일자는 보증금을 지키는 가장 중요한 절차예요</li>
          <li>다른 기기에서도 이어서 체크하려면 로그인 후 계정에 저장해두세요</li>
        </ul>
      </div>

      <div class="side-block">
        <button type="button" class="btn btn-save" id="btnSave">내 계정에 저장하기</button>
        <p class="save-status" id="saveStatus"></p>
      </div>

      <div class="side-block">
        <button type="button" class="btn btn-outline" id="btnReset">체크리스트 초기화</button>
      </div>
    </aside>
  </div>
</div>

<script>
  // 계정마다 브라우저 저장 공간을 따로 사용 (비로그인은 guest)
  const STORAGE_SUFFIX = '<%= storageSuffix %>';
  const STORAGE_KEY = 'jpg_checklist_state_v1_' + STORAGE_SUFFIX;
  const SUMMARY_KEY = 'jpg_checklist_summary_v1_' + STORAGE_SUFFIX;

  const categories = document.querySelectorAll('.cat-card');
  const ringFill = document.getElementById('ringFill');
  const ringLabel = document.getElementById('ringLabel');
  const heroText = document.getElementById('heroText');
  const miniRows = document.querySelectorAll('.mini-progress-row');
  const CIRC = 226.19;

  // ── 계정 저장 관련 (JSP에서 전달) ──
  const IS_LOGIN    = <%= isLogin %>;
  const LOAD_ERROR  = <%= loadError %>;
  const SERVER_KEYS = <%= savedJson %>;   // 저장 기록이 없으면 null
  const SAVE_URL    = '<%= request.getContextPath() %>/checklist/save';

  const btnSave    = document.getElementById('btnSave');
  const saveStatus = document.getElementById('saveStatus');
  let savedSnapshot = SERVER_KEYS ? SERVER_KEYS.slice().sort().join(',') : '';

  // data-key(c{카테고리}_{항목})는 JSP에서 서버 측으로 부여됨

  function loadState(){
    try{
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : {};
    }catch(err){ return {}; }
  }

  function saveState(state){
    try{ localStorage.setItem(STORAGE_KEY, JSON.stringify(state)); }
    catch(err){ /* storage unavailable, ignore */ }
  }

  function saveSummary(summary){
    try{ localStorage.setItem(SUMMARY_KEY, JSON.stringify(summary)); }
    catch(err){ /* storage unavailable, ignore */ }
  }

  function applyState(state){
    categories.forEach(cat => {
      cat.querySelectorAll('input[type=checkbox]').forEach(box => {
        box.checked = !!state[box.dataset.key];
      });
    });
  }

  function updateAll(persist){
    let totalChecked = 0, totalItems = 0;
    const state = {};
    const catSummary = [];

    categories.forEach((cat, idx) => {
      const boxes = cat.querySelectorAll('input[type=checkbox]');
      const checked = cat.querySelectorAll('input[type=checkbox]:checked');
      const countEl = cat.querySelector('.cat-count b');
      countEl.textContent = checked.length;
      const catName = cat.querySelector('.cat-title').textContent;

      boxes.forEach(box => {
        const item = box.closest('.check-item');
        item.classList.toggle('done', box.checked);
        state[box.dataset.key] = box.checked;
      });

      totalChecked += checked.length;
      totalItems += boxes.length;
      catSummary.push({ name: catName, checked: checked.length, total: boxes.length });

      const row = miniRows[idx];
      if(row){
        const pct = boxes.length ? Math.round((checked.length / boxes.length) * 100) : 0;
        row.querySelector('.fill').style.width = pct + '%';
        row.querySelector('.pct').textContent = pct + '%';
      }
    });

    heroText.textContent = totalChecked + ' / ' + totalItems + '개 완료했어요';
    const overallPct = totalItems ? totalChecked / totalItems : 0;
    ringFill.style.strokeDashoffset = CIRC - (CIRC * overallPct);
    ringLabel.textContent = Math.round(overallPct * 100) + '%';

    if(persist){
      saveState(state);
      saveSummary({ checked: totalChecked, total: totalItems, categories: catSummary, updatedAt: Date.now() });
    }
  }

  // 현재 체크된 키 목록 (정렬)
  function currentKeys(){
    return Array.from(document.querySelectorAll('#checklistMain input[type=checkbox]:checked'))
      .map(b => b.dataset.key).sort();
  }

  function isDirty(){
    return IS_LOGIN && currentKeys().join(',') !== savedSnapshot;
  }

  function setStatus(text, cls){
    saveStatus.textContent = text;
    saveStatus.className = 'save-status' + (cls ? ' ' + cls : '');
  }

  function updateSaveStatus(){
    if(!IS_LOGIN){
      setStatus('로그인하면 체크한 내용을 계정에 저장할 수 있어요');
    }else if(LOAD_ERROR && SERVER_KEYS === null){
      setStatus('저장된 내용을 불러오지 못했어요. 잠시 후 다시 시도해주세요', 'dirty');
    }else if(isDirty()){
      setStatus('저장하지 않은 변경사항이 있어요', 'dirty');
    }else if(SERVER_KEYS === null && savedSnapshot === ''){
      setStatus('아직 계정에 저장된 체크리스트가 없어요');
    }else{
      setStatus('계정에 저장된 상태와 같아요', 'ok');
    }
  }

  function saveToAccount(){
    if(!IS_LOGIN){
      alert('로그인 후 이용할 수 있어요.');
      return;
    }
    const keys = currentKeys();
    const total = document.querySelectorAll('#checklistMain input[type=checkbox]').length;
    const body = new URLSearchParams();
    keys.forEach(k => body.append('keys', k));
    body.append('total', total);

    btnSave.disabled = true;
    setStatus('저장 중...');

    fetch(SAVE_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
      body: body
    })
    .then(res => res.json().then(data => ({ status: res.status, data })))
    .then(({ status, data }) => {
      if(status === 401){
        alert('로그인이 만료되었어요. 다시 로그인해주세요.');
        updateSaveStatus();
        return;
      }
      if(!data.ok) throw new Error(data.message || 'save failed');
      savedSnapshot = keys.join(',');
      setStatus('저장했어요! (' + keys.length + ' / ' + total + ')', 'ok');
    })
    .catch(err => {
      console.error(err);
      setStatus('저장에 실패했어요. 잠시 후 다시 시도해주세요', 'dirty');
    })
    .finally(() => { btnSave.disabled = false; });
  }

  document.getElementById('checklistMain').addEventListener('change', function(e){
    if(e.target.type === 'checkbox'){
      updateAll(true);
      updateSaveStatus();
    }
  });

  document.getElementById('btnReset').addEventListener('click', function(){
    if(!confirm('체크한 내용을 모두 해제할까요?')) return;
    document.querySelectorAll('#checklistMain input[type=checkbox]').forEach(b => b.checked = false);
    updateAll(true);
    updateSaveStatus();
  });

  btnSave.addEventListener('click', saveToAccount);

  // 저장하지 않고 페이지를 떠나려 할 때 경고
  window.addEventListener('beforeunload', function(e){
    if(isDirty()){ e.preventDefault(); e.returnValue = ''; }
  });

  // ── 초기 상태 ──
  // 로그인 + 계정 저장 기록 있음 → 계정(DB) 기준
  // 그 외 → 이 계정(또는 guest) 전용 브라우저 저장값 기준
  if(IS_LOGIN && SERVER_KEYS){
    const st = {};
    SERVER_KEYS.forEach(k => st[k] = true);
    applyState(st);
  }else{
    applyState(loadState());
  }
  updateAll(true);
  updateSaveStatus();
</script>

</body>
</html>
