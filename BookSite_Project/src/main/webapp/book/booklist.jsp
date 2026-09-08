<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="book.BookDAO" %>
<%@ page import="book.BookVO" %>
<%@ page import="java.util.List" %>
<%
//------------------ 페이지 처리
	int pageSize = 8;
	int number = 0; //현재 페이지의 시작 번호
	String pageNum = null;
	
	pageNum = request.getParameter("pageNum");
	if(pageNum == null) {
		pageNum = "1";
	}
	
	int currentPage = Integer.parseInt(pageNum);   //1			 //2
	int startRow = (currentPage - 1)* pageSize + 1;//(1-1)*10+1=1, (2-1)*10+1=11 
	int endRow = currentPage * pageSize;		   //1*10=10,      2*20=20
	
	//number = count - (currentPage - 1) * pageSize; //12-(1-1)*10=12, 12-(2-1)*10=2
	//------------------

	int count = 0; //총글수	

	List<BookVO> alist = null;
	BookDAO bdao = BookDAO.getInstance();

	String sword = request.getParameter("sword");
	if (sword==null || sword.equals("")) {
		count = bdao.getArticleCount();	
		if(count > 0) {
	alist = bdao.getArticles(startRow, pageSize);
		}
	} else {
		count = bdao.getArticleCount("%"+sword+"%");	
		if(count > 0) {
	alist = bdao.getArticles(startRow, pageSize, "%"+sword+"%");
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 소개</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/book.css" rel="stylesheet" type="text/css">
<script>
function search_input() {
    if (!document.search_form.sword.value) {
        alert("검색어를 입력하세요");    
        document.login_form.id.focus();
        return;
    }    
    document.search_form.submit();
}
</script>
</head>
<body>
<header>
  <jsp:include page="../module/header.jsp" flush="false"/>
</header>
<section>
  <div class="search_box">
  <form name="search_form" method="get" action="booklist.jsp">
	 <input type="text" name="sword" placeholder="Search" />
	 <a href="#"><span onclick="search_input()"><b>검 색</b></span></a>
  </form>
  </div>
  
  <h2>도 서 소 개</h2>

<%
if(alist != null) {
for(int i=0; i<alist.size(); i++) {
		BookVO article = alist.get(i);
%>  
  	<article class="at_list">  
     	<div class="view_box">
			<div class="view_box_block">
			   <a href="bookcontent.jsp?bnum=<%=article.getBnum()%>&pageNum=<%=currentPage%>">
			      <img class="img_list" src="../bookimg/<%=article.getBimage()%>" alt="상세보기" /></a>
			</div>
			<div class="info">
				<br>
				<p><a href="bookcontent.jsp?bnum=<%=article.getBnum()%>&pageNum=<%=currentPage%>"><%=article.getBtitle()%></a></p>
				<br>
				<p class="book_writer"><%=article.getAuthor()%></p>
			</div>
		</div>
  	</article>
<%}	} %>
	<br>
	<div class="page">
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
			<a href="booklist.jsp?pageNum=<%=startPage-10%>">[이전]</a>
<%			
		}
		
		for(int i=startPage; i<=endPage; i++) {
%>
			<a href="booklist.jsp?pageNum=<%=i%>">[ <%= i %> ]</a>
<%			
		}
		
		if(endPage < pageCount) {
%>
			<a href="booklist.jsp?pageNum=<%=startPage+10%>">[다음]</a>
<%			
		}		
	}
//------------------
%>
	</div>
</section>
<footer>
  <jsp:include page="../module/footer.jsp" flush="false"/>
</footer>
</body>
</html>