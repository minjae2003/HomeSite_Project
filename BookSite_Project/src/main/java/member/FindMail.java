package member;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import mail.SesMailer;
import util.HtmlUtil;
import util.SiteInfo;

/** 아이디 찾기 / 비밀번호 재설정 안내 메일 */
public final class FindMail {
    private FindMail() {}

    /**
     * 메일 속 링크 주소. 운영 서버는 항상 SITE_URL로 고정한다
     * (요청의 Host 헤더를 쓰면 공격자가 가짜 도메인 링크가 담긴 재설정 메일을 보내게 만들 수 있음).
     */
    public static String siteBase(HttpServletRequest req) {
        String host = req.getServerName() == null ? "" : req.getServerName().toLowerCase();
        if ("localhost".equals(host) || "127.0.0.1".equals(host)) {
            return req.getScheme() + "://" + host + ":" + req.getServerPort() + req.getContextPath();
        }
        return SiteInfo.SITE_URL + req.getContextPath();
    }

    public static boolean sendIds(String to, List<String> ids, String base) {
        StringBuilder text = new StringBuilder();
        StringBuilder li = new StringBuilder();
        for (String id : ids) {
            text.append("  - ").append(id).append('\n');
            li.append("<li style=\"font-size:16px;font-weight:700;margin:4px 0\">").append(HtmlUtil.esc(id)).append("</li>");
        }
        String login = base + "/member/loginForm.jsp";
        String subject = "[" + SiteInfo.SITE_NAME + "] 아이디 찾기 안내";
        String t = SiteInfo.SITE_NAME + " 아이디 찾기를 요청하셨어요.\n\n이 이메일로 가입된 아이디:\n" + text
                + "\n로그인: " + login + "\n\n" + footerText();
        String h = wrap("아이디 찾기 안내",
                "<p>이 이메일로 가입된 아이디예요.</p><ul style=\"padding-left:20px\">" + li + "</ul>"
                + button(login, "로그인하기"));
        return SesMailer.send(to, subject, t, h);
    }

    public static boolean sendReset(String to, String id, String link) {
        long min = PasswordResetDAO.VALID_MS / 60000;
        String subject = "[" + SiteInfo.SITE_NAME + "] 비밀번호 재설정 안내";
        String t = SiteInfo.SITE_NAME + " 계정(" + FindLimiter.mask(id) + ")의 비밀번호 재설정을 요청하셨어요.\n\n"
                + "아래 링크에서 새 비밀번호를 설정해 주세요. (" + min + "분 동안 한 번만 사용할 수 있어요)\n" + link + "\n\n" + footerText();
        String h = wrap("비밀번호 재설정 안내",
                "<p><b>" + HtmlUtil.esc(FindLimiter.mask(id)) + "</b> 계정의 비밀번호 재설정을 요청하셨어요.<br>"
                + "아래 버튼을 눌러 새 비밀번호를 설정해 주세요.</p>"
                + button(link, "새 비밀번호 설정하기")
                + "<p style=\"font-size:12px;color:#6b7280\">링크는 " + min + "분 동안 한 번만 사용할 수 있어요.<br>"
                + "버튼이 눌리지 않으면 이 주소를 복사해 브라우저에 붙여넣어 주세요.<br>"
                + "<span style=\"word-break:break-all\">" + HtmlUtil.esc(link) + "</span></p>");
        return SesMailer.send(to, subject, t, h);
    }

    private static String footerText() {
        return "직접 요청하지 않으셨다면 이 메일은 무시하셔도 됩니다. 비밀번호는 바뀌지 않아요.\n"
                + "문의: " + SiteInfo.CONTACT_EMAIL + "\n" + SiteInfo.SITE_NAME + " " + SiteInfo.SITE_URL;
    }

    private static String button(String href, String label) {
        return "<p style=\"margin:24px 0\"><a href=\"" + HtmlUtil.esc(href) + "\" style=\"display:inline-block;background:#f97316;color:#ffffff;"
                + "padding:12px 22px;border-radius:10px;font-weight:700;text-decoration:none\">" + HtmlUtil.esc(label) + "</a></p>";
    }

    private static String wrap(String title, String body) {
        return "<div style=\"font-family:'Malgun Gothic',Apple SD Gothic Neo,sans-serif;max-width:520px;margin:0 auto;padding:24px;color:#1f2937;line-height:1.6\">"
                + "<h2 style=\"margin:0 0 4px\">🏠 " + HtmlUtil.esc(SiteInfo.SITE_NAME) + "</h2>"
                + "<h3 style=\"margin:0 0 16px;color:#f97316\">" + HtmlUtil.esc(title) + "</h3>" + body
                + "<hr style=\"border:none;border-top:1px solid #e5e7eb;margin:24px 0\">"
                + "<p style=\"font-size:12px;color:#9ca3af\">직접 요청하지 않으셨다면 이 메일은 무시하셔도 됩니다. 비밀번호는 바뀌지 않아요.<br>"
                + "문의: " + HtmlUtil.esc(SiteInfo.CONTACT_EMAIL) + "</p></div>";
    }
}
