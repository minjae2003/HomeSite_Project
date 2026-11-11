<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="filter.BannedWordDAO, filter.WordFilter" %>
<%
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("bannedWords.jsp");
        return;
    }
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    BannedWordDAO dao = BannedWordDAO.getInstance();
    String action = request.getParameter("action");
    String msg = null;

    if ("add".equals(action)) {
        String word = request.getParameter("word");
        word = word == null ? "" : word.trim();
        String type = "ALLOW".equals(request.getParameter("type")) ? "ALLOW" : "BAN";
        if (word.isEmpty() || word.length() > 50) msg = "단어는 1~50자로 입력해 주세요.";
        else if (!dao.add(word, type)) msg = "저장 중 오류가 발생했습니다.";
    } else if ("delete".equals(action)) {
        String id = request.getParameter("id");
        if (id != null && id.matches("\\d{1,9}")) dao.delete(Integer.parseInt(id));
    } else if ("defaults".equals(action)) {
        dao.addDefaults();
    }
    WordFilter.invalidate();

    if (msg != null) out.println("<script>alert('" + msg + "'); location.href='bannedWords.jsp';</script>");
    else response.sendRedirect("bannedWords.jsp");
%>
