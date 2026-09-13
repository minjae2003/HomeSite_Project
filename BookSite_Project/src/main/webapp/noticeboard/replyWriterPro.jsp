<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ page import="replyfreeboard.ReplyfreeboardDAO" %>
    
    
    <%request.setCharacterEncoding("UTF-8");%>
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%
	String id = (String)session.getAttribute("id");
	if(id == null && id.equals("")) {
		response.sendRedirect("../main/main.jsp");
	}else{
	%>
	<jsp:useBean id="reply" class="replyfreeboard.ReplyfreeboardVO">
        <jsp:setProperty name="reply" property="*" />
    </jsp:useBean>
	<%
	ReplyfreeboardDAO rdao = ReplyfreeboardDAO.getInstance();
	rdao.insertReplyfreeboard(reply);
	response.sendRedirect("content.jsp?num="+reply.getRef());
	
	}
	%>
</body>
</html>