package upload;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
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
import util.HtmlUtil;
import util.RichText;

@WebServlet("/board/upload")
@MultipartConfig(
    maxFileSize = 50L * 1024 * 1024,
    maxRequestSize = 300L * 1024 * 1024,
    fileSizeThreshold = 1024 * 1024
)
public class BoardUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 확장자 기반 화이트리스트 판별 (한글 hwp 등은 브라우저가 Content-Type을 제대로 안 보내는 경우가 많아
    // Content-Type이 아니라 확장자로 분류한다 - 목록에 없는 확장자는 보안을 위해 아예 업로드를 거부한다)
    private static final Set<String> IMAGE_EXT = new HashSet<String>(Arrays.asList(
            "jpg", "jpeg", "png", "gif", "bmp", "webp"));   // svg는 내부에 스크립트를 넣을 수 있어(XSS) 제외
    private static final Set<String> VIDEO_EXT = new HashSet<String>(Arrays.asList(
            "mp4", "mov", "avi", "wmv", "mkv", "webm", "flv", "m4v"));
    private static final Set<String> DOC_EXT = new HashSet<String>(Arrays.asList(
            "hwp", "hwpx", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "csv", "zip", "rar", "7z"));

    private static String fileTypeOf(String ext) {
        String e = ext.toLowerCase();
        if (IMAGE_EXT.contains(e)) return "IMAGE";
        if (VIDEO_EXT.contains(e)) return "VIDEO";
        if (DOC_EXT.contains(e)) return "FILE";
        return null;
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
        String noticeType = request.getParameter("noticeType");
        String redirectBoard = request.getParameter("redirectBoard");
        String subject = request.getParameter("subject");
        String content = request.getParameter("content");
        String pageNum = request.getParameter("pageNum");

        boolean isAdmin = "ADMIN".equals(sessionRole);
        boolean isNotice = (noticeType != null && !noticeType.trim().isEmpty());

        boolean noticeFromFreeboard = false;
        if (!isNotice && category != null && "NOTICE".equalsIgnoreCase(category.trim())) {
            isNotice = true;
            noticeFromFreeboard = true;
            noticeType = "NORMAL";
        }

        if (isNotice && !isAdmin) {
            alertAndRedirect(response, "공지사항은 관리자만 작성할 수 있습니다.", request.getContextPath() + "/noticeboard/list.jsp");
            return;
        }
        if (isNotice && !"FIX".equals(noticeType)) noticeType = "NORMAL";

        if (category == null) category = "";
        category = category.trim().toUpperCase();
        boolean allowedCategory = "FREE".equals(category) || "TIP".equals(category)
                || "QNA".equals(category) || "RECIPE".equals(category);
        if (!allowedCategory) category = "FREE";

        redirectBoard = isNotice ? "noticeboard" : "freeboard";
        if (pageNum == null || pageNum.trim().isEmpty()) pageNum = "1";

        if (subject == null || content == null || subject.trim().isEmpty()) {
            alertAndRedirect(response, "제목과 내용을 입력해 주세요.", null);
            return;
        }

        boolean html = "html".equals(request.getParameter("contentFormat"));
        if (html) content = RichText.sanitize(content);

        // 금칙어 검사 (관리자 제외)
        if (!isAdmin) {
            String plain = html ? RichText.toText(RichText.MARK + content) : content;
            String badWord = filter.WordFilter.find(subject + "\n" + plain);
            if (badWord != null) {
                alertAndRedirect(response, filter.WordFilter.message(badWord), null);
                return;
            }
        }

        String uploadDir = getServletContext().getRealPath("/uploads");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        List<BoardFileVO> newFiles = new ArrayList<BoardFileVO>();
        StringBuilder appendedImages = new StringBuilder();
        for (Part part : request.getParts()) {
            if (!"files".equals(part.getName())) continue;

            String submittedName = part.getSubmittedFileName();
            if (submittedName == null || submittedName.trim().isEmpty()) continue;

            String ext = "";
            int dotIdx = submittedName.lastIndexOf('.');
            if (dotIdx != -1 && dotIdx < submittedName.length() - 1) {
                ext = submittedName.substring(dotIdx + 1);
            }

            String fileType = fileTypeOf(ext);
            if (fileType == null) continue; // 허용 확장자가 아니면 무시 (보안: 실행 가능한 파일 업로드 차단)

            if ("IMAGE".equals(fileType) && !isAdmin) {
                byte[] bytes;
                try (java.io.InputStream in = part.getInputStream()) { bytes = in.readAllBytes(); }
                moderation.ImageModeration.Result mod = moderation.ImageModeration.check(bytes, ext, sessionUserId);
                if (mod.rejected()) {
                    if (mod.label != null) System.err.println("[ImageModeration] 차단: " + sessionUserId + " / " + mod.label);
                    for (BoardFileVO f : newFiles) new File(uploadDir, f.getSavedName()).delete();
                    alertAndRedirect(response, mod.message(), null);
                    return;
                }
            }
            String savedName = UUID.randomUUID().toString().replace("-", "") + "." + ext.toLowerCase();
            part.write(uploadDir + File.separator + savedName);

            BoardFileVO fileVO = new BoardFileVO();
            fileVO.setOriginalName(submittedName);
            fileVO.setSavedName(savedName);
            fileVO.setFileType(fileType);
            fileVO.setFileSize(part.getSize());
            newFiles.add(fileVO);

            if (html && "IMAGE".equals(fileType)) {
                appendedImages.append("<p><img src=\"").append(HtmlUtil.esc(request.getContextPath() + fileVO.getWebPath()))
                              .append("\" alt=\"").append(HtmlUtil.esc(submittedName)).append("\"></p>");
            }
        }

        if (html) {
            content = content + appendedImages;
            if (!RichText.hasContent(content)) {
                for (BoardFileVO f : newFiles) new File(uploadDir, f.getSavedName()).delete();
                alertAndRedirect(response, "내용을 입력해 주세요.", null);
                return;
            }
            content = RichText.MARK + content;
        }

        BoardDAO boardDao = BoardDAO.getInstance();
        int boardNum;

        if (numParam == null || numParam.trim().isEmpty()) {
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
                for (BoardFileVO f : newFiles) new File(uploadDir, f.getSavedName()).delete();
                alertAndRedirect(response, "게시글 등록에 실패했습니다.", null);
                return;
            }
        } else {
            if (!numParam.trim().matches("\\d{1,9}")) {
                alertAndRedirect(response, "잘못된 접근입니다.", null);
                return;
            }
            boardNum = Integer.parseInt(numParam.trim());
            BoardVO existing = boardDao.getBoardDetail(boardNum);
            if (existing == null) {
                alertAndRedirect(response, "존재하지 않는 게시글입니다.", null);
                return;
            }
            boolean isOwnerOrAdmin = sessionUserId.equals(existing.getWriterId()) || isAdmin;
            // 기존 글이 공지사항이면 관리자만 수정 가능 (자유게시판 수정 폼으로 우회하는 것도 차단)
            if ("NOTICE".equals(existing.getCategory()) && !isAdmin) isOwnerOrAdmin = false;
            if (!isOwnerOrAdmin) {
                for (BoardFileVO f : newFiles) new File(uploadDir, f.getSavedName()).delete();
                alertAndRedirect(response, "수정 권한이 없습니다.", null);
                return;
            }

            BoardVO article = new BoardVO();
            article.setNum(boardNum);
            article.setSubject(subject);
            article.setContent(content);

            if (isNotice) {
                if (noticeFromFreeboard) noticeType = "FIX".equals(existing.getNoticeType()) ? "FIX" : "NORMAL";
                article.setNoticeType(noticeType);
                boardDao.updateNotice(article);
            } else {
                article.setCategory(category);
                boardDao.updateArticle(article);
            }
        }

        BoardFileDAO fileDao = BoardFileDAO.getInstance();

        List<BoardFileVO> already = fileDao.getFiles(boardNum);
        int order = already.size();
        Set<String> registered = new HashSet<String>();
        for (BoardFileVO f : already) registered.add(f.getSavedName());

        for (BoardFileVO fileVO : newFiles) {
            order++;
            fileVO.setBoardNum(boardNum);
            fileVO.setUploadOrder(order);
            fileDao.insertFile(fileVO);
            registered.add(fileVO.getSavedName());
        }

        if (html) {
            Set<String> used = RichText.uploadNames(content);

            synchronized (session) {
                @SuppressWarnings("unchecked")
                Set<String> pending = (Set<String>) session.getAttribute(EditorImageServlet.SESSION_KEY);
                for (String name : used) {
                    if (registered.contains(name) || pending == null || !pending.contains(name)) continue;
                    File f = new File(uploadDir, name);
                    if (!f.exists()) continue;
                    order++;
                    BoardFileVO fileVO = new BoardFileVO();
                    fileVO.setBoardNum(boardNum);
                    fileVO.setOriginalName(name);
                    fileVO.setSavedName(name);
                    fileVO.setFileType("IMAGE");
                    fileVO.setFileSize(f.length());
                    fileVO.setUploadOrder(order);
                    fileDao.insertFile(fileVO);
                    pending.remove(name);
                }
            }

            for (BoardFileVO f : already) {
                if (f.isImage() && !used.contains(f.getSavedName())) {
                    fileDao.deleteFile(f.getFileNum());
                    new File(uploadDir, f.getSavedName()).delete();
                }
            }
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