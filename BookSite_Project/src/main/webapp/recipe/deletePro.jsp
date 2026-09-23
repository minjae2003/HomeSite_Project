<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="board.BoardDAO, board.BoardVO, upload.BoardFileDAO, upload.BoardFileVO, java.util.List, java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");

    String numStr = request.getParameter("num");
    String pageNum = request.getParameter("pageNum");

    if (numStr == null || numStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.go(-1);</script>");
        return;
    }

    int num = Integer.parseInt(numStr);
    BoardDAO dao = BoardDAO.getInstance();
    BoardVO board = dao.getBoardDetail(num);

    String sessionUserId = (String) session.getAttribute("id");
    String sessionRole = (String) session.getAttribute("role");

    boolean isOwnerOrAdmin = (sessionUserId != null && (sessionUserId.equals(board.getWriterId()) || "ADMIN".equals(sessionRole))) || (board.getWriterId() == null);
    if (!isOwnerOrAdmin) {
        out.println("<script>alert('삭제 권한이 없습니다.'); history.go(-1);</script>");
        return;
    }

    // 첨부된 실제 파일 삭제 (DB의 BOARD_FILE 행은 게시글 삭제 시 FK ON DELETE CASCADE로 자동 삭제됨)
    List<BoardFileVO> attachedFiles = BoardFileDAO.getInstance().getFiles(num);
    String uploadDir = application.getRealPath("/uploads");
    for (BoardFileVO f : attachedFiles) {
        File physical = new File(uploadDir, f.getSavedName());
        if (physical.exists()) physical.delete();
    }

    dao.deleteArticle(num);

    out.println("<script>alert('게시글이 삭제되었습니다.'); location.href='list.jsp?pageNum=" + pageNum + "';</script>");
%>