<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 로그인 정보 확인
    String id = (String) session.getAttribute("id");
    String name = (String) session.getAttribute("name");


    // 오늘 방문 기록 (세션당 하루 1번)
    visit.VisitDAO.getInstance().recordVisit(session.getId());
%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">


<header>
    <div class="logo"><a href="${pageContext.request.contextPath}/main/index.jsp">🏠 자취의 품격</a></div>
    <nav>
        <ul>
            <li><a href="${pageContext.request.contextPath}/main/index.jsp">HOME</a></li>
            <li><a href="${pageContext.request.contextPath}/noticeboard/list.jsp">NOTICE<small>공지사항</small></a></li>
            <li><a href="${pageContext.request.contextPath}/freeboard/list.jsp">TIPS/BOARD<small>생활 꿀팁/자유게시판</small></a></li>
            <li><a href="${pageContext.request.contextPath}/qna/qnaList.jsp">RECIPES<small>요리레시피</small></a></li>
            <li><a href="${pageContext.request.contextPath}/finalPage/index.jsp">MY PAGE</a></li>
        </ul>
    </nav>

    <!-- 로그인 / 회원가입 / 닉네임 동적 상태 영역 -->
    <div class="header-auth">
    <% if (id == null) { %>
        <!-- 로그아웃 상태 -->
        
        <a href="${pageContext.request.contextPath}/member/loginForm.jsp" class="btn-auth btn-login">로그인</a>
        
        <a href="${pageContext.request.contextPath}/member/memberForm.jsp" class="btn-auth btn-signup">회원가입</a>
    <% } else { %>
        <!-- 로그인 상태 -->
        <a href="${pageContext.request.contextPath}/member/LogoutPro.jsp" class="btn-auth btn-logout">로그아웃</a>
       
        <span class="user-nickname"><strong><%= (name != null && !name.equals("")) ? name : id %></strong> 님</span>
    <% } %>
    </div>
</header>