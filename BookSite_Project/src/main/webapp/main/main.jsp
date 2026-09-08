<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 소개</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
</head>
<body>
<header>
  <jsp:include page="../module/header.jsp" flush="false"/>
</header>
<section>
  <jsp:include page="introList.jsp" flush="false"/>
</section>
<footer>
  <jsp:include page="../module/footer.jsp" flush="false"/>
</footer>
</body>
</html>