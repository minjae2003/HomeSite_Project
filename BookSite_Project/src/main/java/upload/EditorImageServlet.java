package upload;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashSet;
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

/**
 * 글쓰기 에디터에서 사진을 넣을 때 바로 업로드하는 서블릿 (AJAX, 응답은 JSON).
 * 업로드한 파일 이름은 세션에 기억해 두었다가, 글을 저장할 때 본문에 실제로 남아 있는 것만 BOARD_FILE에 등록한다.
 * CSRF 토큰은 X-CSRF-Token 헤더로 받는다 (CsrfFilter에서 검사).
 */
@WebServlet("/board/editor-image")
@MultipartConfig(maxFileSize = 10L * 1024 * 1024, maxRequestSize = 12L * 1024 * 1024, fileSizeThreshold = 1024 * 1024)
public class EditorImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static final String SESSION_KEY = "EDITOR_UPLOADS";
    private static final int MAX_PENDING = 200;
    private static final Set<String> IMAGE_EXT = new HashSet<String>(Arrays.asList(
            "jpg", "jpeg", "png", "gif", "bmp", "webp"));   // svg는 스크립트를 넣을 수 있어 제외

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id") == null) {
            fail(response, 401, "로그인이 필요합니다.");
            return;
        }

        Part part;
        try {
            part = request.getPart("image");
        } catch (IllegalStateException e) {
            fail(response, 413, "사진은 10MB까지 올릴 수 있습니다.");
            return;
        }
        if (part == null || part.getSize() == 0) {
            fail(response, 400, "사진 파일이 없습니다.");
            return;
        }

        String submitted = part.getSubmittedFileName() == null ? "" : part.getSubmittedFileName();
        int dot = submitted.lastIndexOf('.');
        String ext = dot >= 0 ? submitted.substring(dot + 1).toLowerCase() : "";
        if (!IMAGE_EXT.contains(ext) || !looksLikeImage(part)) {
            fail(response, 400, "jpg, png, gif, bmp, webp 사진만 올릴 수 있습니다.");
            return;
        }

        String uploadDir = getServletContext().getRealPath("/uploads");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();
        String savedName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
        part.write(uploadDir + File.separator + savedName);

        synchronized (session) {
            @SuppressWarnings("unchecked")
            Set<String> pending = (Set<String>) session.getAttribute(SESSION_KEY);
            if (pending == null) {
                pending = new LinkedHashSet<String>();
                session.setAttribute(SESSION_KEY, pending);
            }
            if (pending.size() >= MAX_PENDING) pending.remove(pending.iterator().next());
            pending.add(savedName);
        }

        String url = request.getContextPath() + "/uploads/" + savedName;
        response.getWriter().write("{\"ok\":true,\"url\":\"" + url + "\"}");
    }

    // 확장자만 바꾼 가짜 이미지(스크립트 등)를 막기 위해 파일 앞부분(매직 넘버) 확인
    private static boolean looksLikeImage(Part part) throws IOException {
        byte[] h = new byte[12];
        int n;
        try (InputStream in = part.getInputStream()) {
            n = in.read(h);
        }
        if (n < 4) return false;
        int b0 = h[0] & 0xff, b1 = h[1] & 0xff, b2 = h[2] & 0xff, b3 = h[3] & 0xff;
        if (b0 == 0xFF && b1 == 0xD8 && b2 == 0xFF) return true;                         // jpg
        if (b0 == 0x89 && b1 == 0x50 && b2 == 0x4E && b3 == 0x47) return true;           // png
        if (b0 == 'G' && b1 == 'I' && b2 == 'F') return true;                            // gif
        if (b0 == 'B' && b1 == 'M') return true;                                         // bmp
        return n >= 12 && b0 == 'R' && b1 == 'I' && b2 == 'F' && b3 == 'F'
                && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P';           // webp
    }

    private static void fail(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.getWriter().write("{\"ok\":false,\"message\":\"" + message + "\"}");
    }
}
