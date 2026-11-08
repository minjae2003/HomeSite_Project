package seo;

import javax.servlet.http.HttpServletRequest;

/** 검색엔진용 주소(사이트맵, canonical) 기준 URL과 검색봇 판별 */
public final class SiteUrl {
    private SiteUrl() {}

    /** 실제 서비스 주소 (www 유무, http/https 상관없이 이 주소 하나로 통일) */
    public static final String SITE = "https://jachiclass.com";

    /**
     * 기준 주소 + 컨텍스트 경로.
     * jachiclass.com 으로 들어온 요청이면 항상 SITE를 쓰고,
     * 내 PC(localhost) 테스트처럼 다른 주소면 요청 주소를 그대로 쓴다.
     */
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

    /** 글 상세 페이지의 대표 주소 (pageNum/category 같은 부가 파라미터 없이) */
    public static String articleUrl(HttpServletRequest req, int num, String boardType) {
        String dir = "NOTICE".equals(boardType) ? "/noticeboard" : "/freeboard";
        return base(req) + dir + "/content.jsp?num=" + num;
    }

    /**
     * 검색엔진 수집봇·링크 미리보기 봇인지.
     * 봇은 쿠키가 없어 방문할 때마다 새 세션이 생기므로, 조회수/인기글 집계에서 빼야 한다.
     */
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

    /** 사이트 이름과 소개 (검색 결과, 카톡/SNS 미리보기에 쓰임) */
    public static final String SITE_NAME = "자취의 품격";
    public static final String SITE_DESC = "자취의 품격 - 자취생들이 생활 꿀팁, 자취 요리 레시피, 질문과 일상을 나누는 자취 커뮤니티입니다.";

    /** 글 본문에서 검색 결과 설명용 요약 (태그·[img1] 자리표시자 제거, 공백 정리, 최대 max자) */
    public static String excerpt(String content, int max) {
        String text = util.RichText.toText(content);
        text = text.replaceAll("\\[(?:img|video)\\d+\\]", " ").replaceAll("\\s+", " ").trim();
        if (text.length() > max) text = text.substring(0, max).trim() + "…";
        return text;
    }
}
