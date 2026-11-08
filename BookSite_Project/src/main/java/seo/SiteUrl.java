package seo;

import javax.servlet.http.HttpServletRequest;

public final class SiteUrl {
    private SiteUrl() {}

    public static final String SITE = "https://jachiclass.com";

    public static String base(HttpServletRequest req) {
        String host = req.getServerName() == null ? "" : req.getServerName().toLowerCase();
        if (host.equals("jachiclass.com") || host.endsWith(".jachiclass.com")) {
            return SITE + req.getContextPath();
        }
        String scheme = "https".equalsIgnoreCase(req.getHeader("X-Forwarded-Proto")) ? "https" : req.getScheme();
        int port = req.getServerPort();
        boolean defaultPort = ("http".equals(scheme) && port == 80) || ("https".equals(scheme) && port == 443);
        String safeHost = host.replaceAll("[^a-z0-9.\\-]", "");
        return scheme + "://" + safeHost + (defaultPort ? "" : ":" + port) + req.getContextPath();
    }

    public static String articleUrl(HttpServletRequest req, int num, String boardType) {
        String dir = "NOTICE".equals(boardType) ? "/noticeboard" : "/freeboard";
        return base(req) + dir + "/content.jsp?num=" + num;
    }

    public static boolean isBot(HttpServletRequest req) {
        String ua = req.getHeader("User-Agent");
        if (ua == null || ua.trim().isEmpty()) return true;
        ua = ua.toLowerCase();
        String[] keys = { "bot", "crawl", "spider", "slurp", "yeti", "daumoa", "facebookexternalhit",
                          "kakaotalk-scrap", "headlesschrome", "curl/", "wget/", "python-requests", "httpclient" };
        for (String k : keys) {
            if (ua.contains(k)) return true;
        }
        return false;
    }

    public static final String SITE_NAME = "자취의 품격";
    public static final String SITE_DESC = "자취의 품격 - 자취생들이 생활 꿀팁, 자취 요리 레시피, 질문과 일상을 나누는 자취 커뮤니티입니다.";

    public static String excerpt(String content, int max) {
        String text = util.RichText.toText(content);
        text = text.replaceAll("\\[(?:img|video)\\d+\\]", " ").replaceAll("\\s+", " ").trim();
        if (text.length() > max) text = text.substring(0, max).trim() + "…";
        return text;
    }
}
