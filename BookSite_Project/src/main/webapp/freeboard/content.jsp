<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="freeboard.FreeboardDAO" %>
<%@ page import="freeboard.FreeboardVO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="replyfreeboard.ReplyfreeboardVO" %>
<%@ page import="replyfreeboard.ReplyfreeboardDAO" %>
<%@ page import="java.util.List" %>

<%
	request.setCharacterEncoding("UTF-8");

	int num = Integer.parseInt(request.getParameter("num"));

	String pageNumStr = request.getParameter("pageNum");
	if(pageNumStr == null) {
		pageNumStr = "1";
	}
	int pageNum = Integer.parseInt(pageNumStr);

	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

	FreeboardDAO fbdao = FreeboardDAO.getInstance();
	FreeboardVO fb = fbdao.getFreeboard(num);
	
	List<ReplyfreeboardVO> rList = null;
	int rcount = 0;

	ReplyfreeboardDAO rdao = ReplyfreeboardDAO.getInstance();
	rcount = rdao.getReplyFreeboardCount(num);

	if(rcount > 0) {
	    rList = rdao.getReplyFreeboards(num);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 소개</title>

<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">

<script>
	function check_input() {
		if(!document.reply_form.reply.value.trim()) {
			alert("댓글을 입력하세요!");
			document.reply_form.reply.focus();
			return;
		}
		document.reply_form.submit();
	}
	
	function del(num, pageNum) {
		if(confirm("삭제하시겠습니까?")) {
			location.href = "deletePro.jsp?num=" + num + "&pageNum=" + pageNum;
		}
	}
	
	function delReply(rnum, num, pageNum) {
		if(confirm("댓글을 삭제하시겠습니까?")) {
			location.href = "replyDelete.jsp?rnum=" + rnum + "&num=" + num + "&pageNum=" + pageNum;
		}
	}
</script>
</head>

<body>

<header>
  <jsp:include page="../module/header.jsp" flush="false"/>
</header>

<section>
<h2>자유 게시판 > 내용 보기</h2>

<div id="board_box">
<ul id="view_content">
	<li>
		<span class="col1"><b>제 목 : <%= fb.getSubject() %></b></span>
		<span class="col2">
			<%= fb.getWriter() %> |
			<%= sdf.format(fb.getReg_date()) %> |
			조회 <%= fb.getReadcount() %>
		</span>
	</li>
	<li id="text">
		<%= fb.getContent() %>
	</li>
</ul>

<ul class="buttons">
<%
	String id = (String)session.getAttribute("id");

	if(id != null && id.equals(fb.getWriter())) {
%>
	<li>
		<button type="button" onclick="location.href='updateForm.jsp?num=<%= fb.getNum() %>&pageNum=<%= pageNum %>'">
			수정
		</button>
	</li>
	<li>
		<button type="button" onclick="del(<%= fb.getNum() %>, <%= pageNum %>)">
			삭제
		</button>
	</li>
<%
	}
%>
	<li>
		<button type="button" onclick="location.href='list.jsp?pageNum=<%= pageNum %>'">
			목록
		</button>
	</li>
</ul>

<%
if(rcount > 0) {
%>
	<ul id="reply_content">
<%
	for(int i = 0; i < rList.size(); i++) {
		ReplyfreeboardVO reply = rList.get(i);
%>
		<li>
			<span class="col1"><%= reply.getRwriter() %></span>
			<span class="col2"><%= reply.getReply().replace("\r\n", "<br>") %></span>
			<span class="col3"><%= sdf.format(reply.getRreg_date()) %></span>

			<%
				if(id != null && id.equals(reply.getRwriter())) {
			%>
				<span class="col4">
					<button type="button" onclick="delReply(<%= reply.getRnum() %>, <%= num %>, <%= pageNum %>)">
						삭제
					</button>
				</span>
			<%
				}
			%>
		</li>
<%
	}
%>
	</ul>
<%
}
%>

<form name="reply_form" method="post" action="replyWriterPro.jsp">
	<input type="hidden" name="rwriter" value="<%= id %>">
	<input type="hidden" name="ref" value="<%= num %>">
	<input type="hidden" name="pageNum" value="<%= pageNum %>">

	<ul id="reply_form">
	<%
		if(id == null || id.equals("")) {
	%>
		<li> * 댓글은 회원만 가능합니다 * </li>
	<%
		} else {
	%>
		<li>
			<span class="col1"><%= id %></span>
			<span class="col2"><textarea name="reply"></textarea></span>
			<span class="col3">
				<button type="button" onclick="check_input()">입력</button>
			</span>
		</li>
	<%
		}
	%>
	</ul>
</form>

</div>
</section>

<footer>
  <jsp:include page="../module/footer.jsp" flush="false"/>
</footer>

</body>
</html>