<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, upload.BoardFileDAO, upload.BoardFileVO, java.util.List, java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 상태를 바꾸는 요청은 POST만 허용 (GET 링크/이미지 태그로 몰래 호출되는 것 방지, 토큰 검사는 CsrfFilter)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    String numStr = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");

    if (numStr == null || !numStr.trim().matches("\\d{1,9}")) {
        out.println("<script>alert('잘못된 접근입니다.'); history.go(-1);</script>");
        return;
    }
    if (pageNum == null || !pageNum.matches("\\d{1,9}")) pageNum = "1";

    int num = Integer.parseInt(numStr.trim());
    BoardDAO dao = BoardDAO.getInstance();
    BoardVO board = dao.getBoardDetail(num);
    if (board == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='list.jsp';</script>");
        return;
    }

    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");

    boolean isOwnerOrAdmin = sessionUserId != null
            && (sessionUserId.equals(board.getWriterId()) || "ADMIN".equals(sessionRole));
    if ("NOTICE".equals(board.getCategory()) && !"ADMIN".equals(sessionRole)) isOwnerOrAdmin = false;
    if (!isOwnerOrAdmin) {
        out.println("<script>alert('삭제 권한이 없습니다.'); history.go(-1);</script>");
        return;
    }

    List<BoardFileVO> attachedFiles = BoardFileDAO.getInstance().getFiles(num);
    String uploadDir = application.getRealPath("/uploads");
    for (BoardFileVO f : attachedFiles) {
        File physical = new File(uploadDir, f.getSavedName());
        if (physical.exists()) physical.delete();
    }

    dao.deleteArticle(num);

    out.println("<script>alert('게시글이 삭제되었습니다.'); location.href='list.jsp?pageNum=" + pageNum + "';</script>");
%>