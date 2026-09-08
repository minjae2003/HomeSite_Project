<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">

<header>
    <div class="logo"><a href="${pageContext.request.contextPath}/main/index.jsp">🏠 자취의 품격</a></div>
    <nav>
        <ul>
            <li><a href="${pageContext.request.contextPath}/main/index.jsp">HOME</a></li>
            <li><a href="${pageContext.request.contextPath}/book/booklist.jsp">NOTICE<small>공지사항</small></a></li>
            <li><a href="${pageContext.request.contextPath}/freeboard/list.jsp">TIPS<small>생활 꿀팁</small></a></li>
            <li><a href="${pageContext.request.contextPath}/qna/qnaList.jsp">BOARD<small>자유게시판</small></a></li>
            <li><a href="${pageContext.request.contextPath}/qna/qnaList.jsp">RECIPES<small>요리레시피</small></a></li>
            <li><a href="${pageContext.request.contextPath}/finalPage/index.jsp">MY PAGE</a></li>
        </ul>
    </nav>
</header>