<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="inquiry.InquiryDAO, inquiry.InquiryVO, notification.NotificationDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    // 상태를 바꾸는 요청은 POST만 허용 (CSRF 토큰 검사는 CsrfFilter)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("inquiry.jsp");
        return;
    }
    String inqUserId = (String) session.getAttribute("id");
    if (inqUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../member/loginForm.jsp';</script>");
        return;
    }

    String category = request.getParameter("category");
    String subject = request.getParameter("subject");
    String content = request.getParameter("content");
    String pageUrl = request.getParameter("page_url");
    subject = subject == null ? "" : subject.trim();
    content = content == null ? "" : content.trim();
    pageUrl = pageUrl == null ? "" : pageUrl.trim();

    if (!InquiryDAO.isValidCategory(category)) category = "ETC";
    if (subject.length() < 2 || subject.length() > 100) {
        out.println("<script>alert('제목은 2~100자로 입력해 주세요.'); history.back();</script>");
        return;
    }
    if (content.length() < 5 || content.length() > 2000) {
        out.println("<script>alert('내용은 5~2000자로 입력해 주세요.'); history.back();</script>");
        return;
    }
    if (!pageUrl.isEmpty() && (pageUrl.length() > 300 || !pageUrl.matches("^(https?://|/)\\S*$"))) {
        out.println("<script>alert('관련 글 주소가 올바르지 않습니다.'); history.back();</script>");
        return;
    }

    InquiryDAO dao = InquiryDAO.getInstance();
    int recent = dao.countRecent(inqUserId, 60);
    if (recent >= 5) {
        out.println("<script>alert('문의는 1시간에 5건까지 보낼 수 있어요. 잠시 후 다시 시도해 주세요.'); history.back();</script>");
        return;
    }

    InquiryVO vo = new InquiryVO();
    vo.setUserId(inqUserId);
    vo.setCategory(category);
    vo.setSubject(subject);
    vo.setContent(content);
    vo.setPageUrl(pageUrl.isEmpty() ? null : pageUrl);
    int num = dao.insert(vo);
    if (num <= 0) {
        out.println("<script>alert('문의 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'); history.back();</script>");
        return;
    }

    String nick = (String) session.getAttribute("nickname");
    NotificationDAO.getInstance().notifyInquiry(inqUserId, nick != null ? nick : inqUserId, subject, content);

    out.println("<script>alert('문의가 접수되었습니다. 답변이 등록되면 알림으로 알려 드릴게요.'); location.href='myInquiries.jsp';</script>");
%>
