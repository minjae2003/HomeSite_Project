<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="replyfreeboard.ReplyfreeboardVO" %>
<%@ page import="replyfreeboard.ReplyfreeboardDAO" %>
<%@ page import="freeboard.FreeboardDAO" %>
<%@ page import="freeboard.FreeboardVO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>



<%
	int count = 0;
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	List<FreeboardVO> fbList = null;

	FreeboardDAO fbdao = FreeboardDAO.getInstance();

	count = fbdao.getFreeboardCount();

	int rcount =0; //댓글수
	ReplyfreeboardDAO rdao = ReplyfreeboardDAO.getInstance();

	//------------------ 페이지 처리
	int pageSize = 10;//페이지 당 글 수
	int number = 0; //현재 페이지의 시작 번호
	String pageNum = null; //현재 페이지 저장
	 
	pageNum = request.getParameter("pageNum");
	if(pageNum == null) {
		pageNum = "1";
	}

	int currentPage = Integer.parseInt(pageNum);   //1 //2
	int startRow = (currentPage - 1)* pageSize + 1;//(1-1)*10+1=1, (2-1)*10+1=11 
	int endRow = currentPage * pageSize;   //1*10=10,      2*20=20 //오라클용 

	number = count - (currentPage - 1) * pageSize; //12-(1-1)*10=12, 12-(2-1)*10=2
	//------------------
	if(count > 0) {
		fbList = fbdao.getFreeboards(startRow,pageSize);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 소개</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">
</head>
<body>

<header>
  <jsp:include page="../module/header.jsp" flush="false"/>
</header>

<section>
<h2>자유 게시판 > 목록 보기</h2>

<div id="board_box">
<ul id="board_list">
	<li>
		<span class="col1"><b>번호</b></span>
		<span class="col2"><b>제 목</b></span>
		<span class="col3"><b>글쓴이</b></span>
		<span class="col4"><b>등록일</b></span>
		<span class="col5"><b>조회</b></span>
	</li>

<%
	if(fbList != null) {
		for(int i = 0; i < fbList.size(); i++) {
			FreeboardVO fb = fbList.get(i);
			rcount = rdao.getReplyFreeboardCount(fb.getNum());
%>
	<li>
		<span class="col1"><%= number-- %></span>
		<span class="col2"><a href="content.jsp?num=<%= fb.getNum() %>&pageNum=<%=currentPage%>"><%= fb.getSubject() %></a>
			<span class="replycount">
			 <% if(rcount > 0){%>
				[<%=rcount %>]
			 <% } %>
			</span>
		</span>
		<span class="col3"><%= fb.getWriter() %></span>
		<span class="col4"><%= sdf.format(fb.getReg_date()) %></span>
		<span class="col5"><%= fb.getReadcount() %></span>
	</li>
<%
		}
	}
%>
</ul>
<br>
<div class=page>
<%

//------------------페이지 번호 목록
if(count > 0) {
int pageCount = count / pageSize + (count%pageSize==0 ? 0 : 1); //12/10+1=2
int startPage = 1;
if(currentPage%10 != 0) {
startPage = (int)(currentPage/10) * 10 + 1;
} else {
startPage = ((int)(currentPage/10)-1) * 10 + 1;
}

int pageBlock = 10;

int endPage = startPage + pageBlock - 1; //1+10-1=10
if(endPage > pageCount) {
endPage = pageCount;
}

if(startPage > 10) {
%>
<a href="list.jsp?pageNum=<%=startPage-10%>">[이전]</a>
<%
}

for(int i=startPage; i<=endPage; i++) {
%>
<a href="list.jsp?pageNum=<%=i%>">[ <%= i %> ]</a>
<%
}
if(endPage < pageCount) {
%>
<a href="list.jsp?pageNum=<%=startPage+10%>">[다음]</a>
<%
}
}

//------------------

 

%>
</div>
<ul class="buttons">
<li>
<%
	String id = (String)session.getAttribute("id");

	if(id == null || id.equals("")) {
%>
	<a href="javascript:alert('로그인 후 이용해 주세요!')">
		<button>글쓰기</button>
	</a>
<%
	} else {
%>
	<button onclick="location.href='writeForm.jsp'">글쓰기</button>
<%
	}
%>
</li>
</ul>

</div>
</section>

<footer>
  <jsp:include page="../module/footer.jsp" flush="false"/>
</footer>

</body>
</html>