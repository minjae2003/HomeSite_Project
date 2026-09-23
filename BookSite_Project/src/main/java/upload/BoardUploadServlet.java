package upload;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import board.BoardDAO;
import board.BoardVO;

/**
 * 모든 게시판(자유게시판/자취꿀팁/질문답변/요리레시피 등) 공통 글쓰기·수정 + 사진/동영상 업로드 서블릿.
 * writeForm.jsp / updateForm.jsp 의 form action 을 이 서블릿으로 보내면 된다.
 *
 * 필요한 파라미터:
 *  - num          (수정일 때만) 게시글 번호. 없으면 신규 작성으로 처리.
 *  - category     board_type 값 (FREE/TIP/QNA/RECIPE 등) - 공지사항 제출일 때는 무시됨
 *  - noticeType   (공지사항 전용) NORMAL/FIX. 이 파라미터가 있으면 공지사항 제출로 간주해
 *                 insertNotice()/updateNotice()로 처리하고, FIX는 ADMIN만 지정 가능.
 *  - redirectBoard 목록/상세 폴더명 (freeboard, recipe, noticeboard 등) - 완료 후 이동할 경로
 *  - subject, content
 *  - pageNum      (선택) 수정 후 돌아갈 목록 페이지
 *  - files        (선택, 여러 개 가능) 첨부할 이미지/동영상
 */
@WebServlet("/board/upload")
@MultipartConfig(
    maxFileSize = 50L * 1024 * 1024,       // 파일 1개 최대 50MB
    maxRequestSize = 300L * 1024 * 1024,   // 요청 전체 최대 300MB (동영상 여러 개 대비)
    fileSizeThreshold = 1024 * 1024
)
public class BoardUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 확장자 기반 화이트리스트 판별 (한글 hwp 등은 브라우저가 Content-Type을 제대로 안 보내는 경우가 많아
    // Content-Type이 아니라 확장자로 분류한다 - 목록에 없는 확장자는 보안을 위해 아예 업로드를 거부한다)
    private static final Set<String> IMAGE_EXT = new HashSet<String>(Arrays.asList(
            "jpg", "jpeg", "png", "gif", "bmp", "webp", "svg"));
    private static final Set<String> VIDEO_EXT = new HashSet<String>(Arrays.asList(
            "mp4", "mov", "avi", "wmv", "mkv", "webm", "flv", "m4v"));
    private static final Set<String> DOC_EXT = new HashSet<String>(Arrays.asList(
            "hwp", "hwpx", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "csv", "zip", "rar", "7z"));

    private static String fileTypeOf(String ext) {
        String e = ext.toLowerCase();
        if (IMAGE_EXT.contains(e)) return "IMAGE";
        if (VIDEO_EXT.contains(e)) return "VIDEO";
        if (DOC_EXT.contains(e)) return "FILE";
        return null; // 화이트리스트에 없으면 업로드 거부
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("id");

        if (sessionUserId == null) {
            alertAndRedirect(response, "로그인이 필요합니다.", request.getContextPath() + "/member/loginForm.jsp");
            return;
        }

        String sessionUserNick = (String) session.getAttribute("nickname");
        if (sessionUserNick == null) sessionUserNick = (String) session.getAttribute("name");
        if (sessionUserNick == null) sessionUserNick = sessionUserId;
        String sessionRole = (String) session.getAttribute("role");

        String numParam = request.getParameter("num");
        String category = request.getParameter("category");
        String noticeType = request.getParameter("noticeType"); // 있으면 "공지사항 제출"로 간주
        String redirectBoard = request.getParameter("redirectBoard");
        String subject = request.getParameter("subject");
        String content = request.getParameter("content");
        String pageNum = request.getParameter("pageNum");

        boolean isNotice = (noticeType != null && !noticeType.trim().isEmpty());
        if (isNotice && !"ADMIN".equals(sessionRole)) {
            noticeType = "NORMAL"; // 관리자가 아니면 고정공지 지정 무시 (writePro.jsp와 동일한 서버측 강제)
        }

        if (category == null || category.trim().isEmpty()) category = "FREE";
        if (redirectBoard == null || redirectBoard.trim().isEmpty()) redirectBoard = isNotice ? "noticeboard" : "freeboard";
        if (pageNum == null || pageNum.trim().isEmpty()) pageNum = "1";

        if (subject == null || content == null || subject.trim().isEmpty()) {
            alertAndRedirect(response, "제목과 내용을 입력해 주세요.", null);
            return;
        }

        BoardDAO boardDao = BoardDAO.getInstance();
        int boardNum;

        if (numParam == null || numParam.trim().isEmpty()) {
            // 신규 작성
            BoardVO article = new BoardVO();
            article.setWriter(sessionUserNick);
            article.setWriterId(sessionUserId);
            article.setWriterNickname(sessionUserNick);
            article.setSubject(subject);
            article.setContent(content);

            if (isNotice) {
                article.setNoticeType(noticeType);
                boardNum = boardDao.insertNotice(article);
            } else {
                article.setCategory(category);
                boardNum = boardDao.insertArticle(article);
            }

            if (boardNum <= 0) {
                alertAndRedirect(response, "게시글 등록에 실패했습니다.", null);
                return;
            }
        } else {
            // 수정 (권한 체크: 작성자 본인 또는 ADMIN)
            boardNum = Integer.parseInt(numParam);
            BoardVO existing = boardDao.getBoardDetail(boardNum);
            if (existing == null) {
                alertAndRedirect(response, "존재하지 않는 게시글입니다.", null);
                return;
            }
            boolean isOwnerOrAdmin = sessionUserId.equals(existing.getWriterId())
                    || "ADMIN".equals(sessionRole) || existing.getWriterId() == null;
            if (!isOwnerOrAdmin) {
                alertAndRedirect(response, "수정 권한이 없습니다.", null);
                return;
            }

            BoardVO article = new BoardVO();
            article.setNum(boardNum);
            article.setSubject(subject);
            article.setContent(content);

            if (isNotice) {
                // 관리자가 아니면 기존 고정/일반 상태를 그대로 유지 (writePro.jsp/updatePro.jsp와 동일)
                if (!"ADMIN".equals(sessionRole)) {
                    noticeType = existing.getNoticeType();
                }
                article.setNoticeType(noticeType);
                boardDao.updateNotice(article);
            } else {
                article.setCategory(category);
                boardDao.updateArticle(article);
            }
        }

        // 업로드 폴더 준비 (webapp/uploads - 톰캣이 정적 파일로 그대로 서빙)
        String uploadDir = getServletContext().getRealPath("/uploads");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        BoardFileDAO fileDao = BoardFileDAO.getInstance();

        // 수정 시 기존 첨부 개수 뒤로 이어서 순번을 매긴다
        List<BoardFileVO> already = fileDao.getFiles(boardNum);
        int order = already.size();

        for (Part part : request.getParts()) {
            if (!"files".equals(part.getName())) continue;

            String submittedName = part.getSubmittedFileName();
            if (submittedName == null || submittedName.trim().isEmpty()) continue; // 파일 선택 안 한 input

            String ext = "";
            int dotIdx = submittedName.lastIndexOf('.');
            if (dotIdx != -1 && dotIdx < submittedName.length() - 1) {
                ext = submittedName.substring(dotIdx + 1);
            }

            String fileType = fileTypeOf(ext);
            if (fileType == null) continue; // 허용 확장자가 아니면 무시 (보안: 실행 가능한 파일 업로드 차단)

            String savedName = UUID.randomUUID().toString().replace("-", "") + "." + ext.toLowerCase();

            part.write(uploadDir + File.separator + savedName);

            order++;
            BoardFileVO fileVO = new BoardFileVO();
            fileVO.setBoardNum(boardNum);
            fileVO.setOriginalName(submittedName);
            fileVO.setSavedName(savedName);
            fileVO.setFileType(fileType);
            fileVO.setFileSize(part.getSize());
            fileVO.setUploadOrder(order);
            fileDao.insertFile(fileVO);
        }

        response.sendRedirect(request.getContextPath() + "/" + redirectBoard + "/content.jsp?num=" + boardNum + "&pageNum=" + pageNum);
    }

    private void alertAndRedirect(HttpServletResponse response, String message, String location) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<script>");
        out.println("alert('" + message.replace("'", "\\'") + "');");
        if (location != null) {
            out.println("location.href='" + location + "';");
        } else {
            out.println("history.back();");
        }
        out.println("</script>");
        out.flush();
    }
}