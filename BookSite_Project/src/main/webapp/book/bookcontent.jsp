<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="book.BookDAO" %>
<%@ page import="book.BookVO" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
int bnum = Integer.parseInt(request.getParameter("bnum"));
	int pageNum = Integer.parseInt(request.getParameter("pageNum"));

	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");	
	BookDAO bdao = BookDAO.getInstance();
	BookVO article = bdao.getArticle(bnum);
%>
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 소개</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/book.css" rel="stylesheet" type="text/css">
</head>
<body>
<header>
  <jsp:include page="../module/header.jsp" flush="false"/>
</header>
<section>
  <div class="main">
  	<article class="at_content">  
     	<div class="view_context">
			<div class="view_img">
			    <img class="img_content" src="../bookimg/<%=article.getBimage()%>"/>
			    <br>
			    <a href="#"><span id="btn" onclick="document.location.href='booklist.jsp?pageNum=<%=pageNum%>'">목 록</span></a>																			
			</div>
			<div class="view_info">
				<h2><%=article.getBtitle()%></h2>
				<br>
				<ul class="info_list">          
                	<li><span><strong>저 자 </strong></span><%=article.getAuthor()%></li>
                    <li><span><strong>출 판 사 </strong></span><%=article.getPubcom()%></li>
            		<li><span><strong>출 판 일 </strong></span><%=sdf.format(article.getPubdate())%></li>
            		<li><span><strong>페 이 지 </strong></span><%=article.getPage()%> 쪽</li>
                </ul>
                <hr>
				<%=article.getBcontent().replace("\r\n", "<br>")%>                
			</div>
		</div>

  	</article>
  </div>
</section>
<footer>
  <jsp:include page="../module/footer.jsp" flush="false"/>
</footer>
</body>
</html>