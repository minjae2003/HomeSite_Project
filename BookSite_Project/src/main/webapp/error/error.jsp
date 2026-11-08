<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" session="false"%>
<%
    // 공통 에러 페이지 - 에러 코드에 맞는 안내만 보여주고, 예외 내용/스택 트레이스는 절대 출력하지 않음
    // (에러 원인이 DB일 수도 있으므로 header.jsp처럼 DB를 쓰는 파일은 include하지 않음)
    Object codeObj = request.getAttribute("javax.servlet.error.status_code");
    int code = (codeObj instanceof Integer) ? (Integer) codeObj : 500;
    if (exception != null) code = 500;

    String title;
    String desc;
    switch (code) {
        case 400: title = "잘못된 요청이에요";        desc = "요청 형식이 올바르지 않아요. 다시 시도해 주세요."; break;
        case 403: title = "접근 권한이 없어요";        desc = "이 페이지를 볼 수 있는 권한이 없어요."; break;
        case 404: title = "페이지를 찾을 수 없어요";   desc = "주소가 바뀌었거나 삭제된 페이지예요."; break;
        case 405: title = "허용되지 않은 요청이에요";  desc = "올바른 경로로 다시 이용해 주세요."; break;
        default:  title = "일시적인 오류가 발생했어요"; desc = "잠시 후 다시 시도해 주세요. 문제가 계속되면 관리자에게 알려 주세요."; code = 500;
    }
    response.setStatus(code);
    String home = request.getContextPath() + "/main/index.jsp";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= title %> - 자취의 품격</title>
<style>
    body { margin: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center;
           background: #f8fafc; font-family: 'Pretendard', 'Malgun Gothic', sans-serif; color: #334155; }
    .box { text-align: center; padding: 40px 24px; }
    .code { font-size: 64px; font-weight: 800; color: #ff5722; margin: 0; }
    h1 { font-size: 22px; margin: 12px 0 8px; }
    p { color: #64748b; margin: 0 0 28px; }
    a { display: inline-block; padding: 10px 22px; border-radius: 8px; text-decoration: none; font-weight: 700; }
    .home { background: #ff5722; color: #fff; }
    .back { background: #e2e8f0; color: #475569; margin-left: 8px; }
</style>
</head>
<body>
    <div class="box">
        <p class="code"><%= code %></p>
        <h1><%= title %></h1>
        <p><%= desc %></p>
        <a class="home" href="<%= home %>">메인으로</a>
        <a class="back" href="javascript:history.back()">이전 페이지</a>
    </div>
<jsp:include page="/module/footer.jsp" flush="false"/>
</body>
</html>
