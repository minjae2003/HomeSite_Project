package mypage;

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

import member.MemberDAO;

@WebServlet("/mypage/profileSave")
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 6L * 1024 * 1024, fileSizeThreshold = 1024 * 1024)
public class ProfileSaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final Set<String> IMAGE_EXT = new HashSet<String>(Arrays.asList("jpg", "jpeg", "png", "gif", "webp"));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("id");
        String ctx = request.getContextPath();
        if (userId == null) {
            alert(response, "로그인이 필요합니다.", ctx + "/member/loginForm.jsp");
            return;
        }

        // 파일 크기 초과 시 여기서 예외가 남
        Part photo;
        try {
            photo = request.getPart("photo");
        } catch (IllegalStateException e) {
            alert(response, "프로필 사진은 5MB 이하만 올릴 수 있어요.", null);
            return;
        }

        String nickname = trim(request.getParameter("nickname"));
        String bio = trim(request.getParameter("bio"));
        String region = trim(request.getParameter("region"));
        String years = trim(request.getParameter("livingYears"));
        String[] tagParams = request.getParameterValues("tags");
        boolean removePhoto = "Y".equals(request.getParameter("removePhoto"));

        if (nickname.isEmpty() || nickname.length() > 50) {
            alert(response, "닉네임은 1~50자로 입력해 주세요.", null);
            return;
        }
        if (bio.length() > ProfileDAO.BIO_MAX) {
            alert(response, "한줄 소개는 " + ProfileDAO.BIO_MAX + "자까지 입력할 수 있어요.", null);
            return;
        }
        if (!region.isEmpty() && !ProfileDAO.isValidRegion(region)) region = "";
        if (!years.isEmpty() && !ProfileDAO.YEARS.contains(years)) years = "";

        List<String> tags = new ArrayList<String>();
        if (tagParams != null) {
            for (String t : tagParams) {
                if (ProfileDAO.TAGS.contains(t) && !tags.contains(t)) tags.add(t);
            }
        }
        if (tags.size() > ProfileDAO.TAG_MAX) {
            alert(response, "관심 태그는 최대 " + ProfileDAO.TAG_MAX + "개까지 선택할 수 있어요.", null);
            return;
        }

        ProfileDAO dao = ProfileDAO.getInstance();
        ProfileVO old = dao.get(userId);
        String imgName = old.getProfileImg();
        String uploadDir = getServletContext().getRealPath("/uploads/profile");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        String submitted = photo == null ? null : photo.getSubmittedFileName();
        if (submitted != null && !submitted.trim().isEmpty() && photo.getSize() > 0) {
            int dot = submitted.lastIndexOf('.');
            String ext = dot < 0 ? "" : submitted.substring(dot + 1).toLowerCase();
            String contentType = photo.getContentType() == null ? "" : photo.getContentType();
            if (!IMAGE_EXT.contains(ext) || !contentType.startsWith("image/")) {
                alert(response, "프로필 사진은 jpg, png, gif, webp 파일만 올릴 수 있어요.", null);
                return;
            }
            String newName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            photo.write(uploadDir + File.separator + newName);
            deleteFile(uploadDir, imgName);
            imgName = newName;
        } else if (removePhoto) {
            deleteFile(uploadDir, imgName);
            imgName = null;
        }

        ProfileVO vo = new ProfileVO();
        vo.setUserId(userId);
        vo.setProfileImg(imgName);
        vo.setBio(bio);
        vo.setRegion(region);
        vo.setLivingYears(years);
        vo.setTags(String.join(",", tags));

        boolean okProfile = dao.save(vo);
        boolean okNick = MemberDAO.getInstance().updateNickname(userId, nickname);
        if (okNick) session.setAttribute("nickname", nickname);

        if (okProfile && okNick) {
            alert(response, "프로필이 저장되었습니다.", ctx + "/mypage/index.jsp");
        } else {
            alert(response, "프로필 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.", null);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/mypage/profileEdit.jsp");
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static void deleteFile(String dir, String name) {
        if (name == null || name.isEmpty() || name.contains("/") || name.contains("\\") || name.contains("..")) return;
        File f = new File(dir, name);
        if (f.exists()) f.delete();
    }

    private static void alert(HttpServletResponse response, String message, String location) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<script>");
        out.println("alert('" + message.replace("'", "\\'") + "');");
        out.println(location != null ? "location.href='" + location + "';" : "history.back();");
        out.println("</script>");
        out.flush();
    }
}