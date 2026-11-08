package preview;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.Inet4Address;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.URI;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import board.BoardDAO;
import board.BoardVO;
import util.RichText;

/**
 * 게시글 링크 미리보기 카드 정보 (GET /link-preview?num=글번호&url=주소).
 * ※ SSRF 방지: 그 글에 있는 링크만, 공인 IP·기본 포트만 허용, 리다이렉트마다 다시 검사
 */
@WebServlet("/link-preview")
public class LinkPreviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final int MAX_BYTES = 512 * 1024;
    private static final long CACHE_TTL = 12L * 60 * 60 * 1000;
    private static final int CACHE_MAX = 500;
    private static final int FETCH_PER_MINUTE = 30;
    private static final String UA = "Mozilla/5.0 (compatible; JachiclassLinkPreview/1.0; +https://jachiclass.com)";

    private static final Map<String, Entry> CACHE = new LinkedHashMap<String, Entry>(64, 0.75f, true) {
        private static final long serialVersionUID = 1L;
        @Override protected boolean removeEldestEntry(Map.Entry<String, Entry> e) { return size() > CACHE_MAX; }
    };
    private static long windowStart = 0;
    private static int windowCount = 0;

    private static final class Entry {
        final String json; final long at;
        Entry(String json) { this.json = json; this.at = System.currentTimeMillis(); }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Cache-Control", "private, max-age=600");

        String numStr = request.getParameter("num");
        String url = request.getParameter("url");
        if (numStr == null || !numStr.matches("\\d{1,9}") || url == null || url.length() > 1000) {
            fail(response, 400);
            return;
        }
        BoardVO article = BoardDAO.getInstance().getBoardDetail(Integer.parseInt(numStr));
        if (article == null || !RichText.linkUrls(article.getContent()).contains(url)) {
            fail(response, 404);
            return;
        }

        String json;
        synchronized (CACHE) {
            Entry e = CACHE.get(url);
            json = (e != null && System.currentTimeMillis() - e.at < CACHE_TTL) ? e.json : null;
        }
        if (json == null) {
            if (!takeFetchSlot()) {
                fail(response, 429);
                return;
            }
            json = buildJson(url);
            synchronized (CACHE) { CACHE.put(url, new Entry(json)); }
        }
        response.getWriter().write(json);
    }

    private static synchronized boolean takeFetchSlot() {
        long now = System.currentTimeMillis();
        if (now - windowStart > 60_000) { windowStart = now; windowCount = 0; }
        return ++windowCount <= FETCH_PER_MINUTE;
    }

    private static final java.util.regex.Pattern YT = java.util.regex.Pattern.compile(
        "^https?://(?:(?:www|m|music)\\.)?(?:youtube\\.com/(?:watch\\?(?:.*&)?v=|shorts/|live/|embed/)|youtu\\.be/)([A-Za-z0-9_-]{11})(?:[?&#/].*)?$");

    static String youtubeId(String url) {
        java.util.regex.Matcher m = YT.matcher(url);
        return m.matches() ? m.group(1) : null;
    }

    private static String youtubeJson(String url, String id) {
        String title = "", author = "";
        try {
            String api = "https://www.youtube.com/oembed?format=json&url="
                       + java.net.URLEncoder.encode("https://www.youtube.com/watch?v=" + id, "UTF-8");
            String body = fetchText(api, "application/json");
            if (body != null) {
                title = jsonString(body, "title");
                author = jsonString(body, "author_name");
            }
        } catch (Exception ignore) {}
        return "{\"ok\":true"
             + ",\"url\":" + js(url)
             + ",\"title\":" + js(cut(title.isEmpty() ? "YouTube 동영상" : title, 100))
             + ",\"desc\":" + js(cut(author.isEmpty() ? "" : author + " · YouTube", 200))
             + ",\"site\":\"YouTube\""
             + ",\"video\":" + js(id)
             + ",\"image\":" + js("https://i.ytimg.com/vi/" + id + "/hqdefault.jpg") + "}";
    }

    private static String fetchText(String url, String accept) throws Exception {
        URL u = new URL(url);
        if (!isSafeTarget(u)) return null;
        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setInstanceFollowRedirects(false);
        conn.setConnectTimeout(3000);
        conn.setReadTimeout(4000);
        conn.setRequestProperty("User-Agent", UA);
        conn.setRequestProperty("Accept", accept);
        try {
            if (conn.getResponseCode() != 200) return null;
            try (InputStream in = conn.getInputStream()) {
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                byte[] buf = new byte[4096];
                int n, total = 0;
                while ((n = in.read(buf)) != -1 && total < 64 * 1024) { out.write(buf, 0, n); total += n; }
                return new String(out.toByteArray(), "UTF-8");
            }
        } finally {
            conn.disconnect();
        }
    }

    static String jsonString(String json, String key) {
        java.util.regex.Matcher m = java.util.regex.Pattern.compile(
            "\"" + java.util.regex.Pattern.quote(key) + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"").matcher(json);
        if (!m.find()) return "";
        String raw = m.group(1);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < raw.length(); i++) {
            char c = raw.charAt(i);
            if (c != '\\' || i + 1 >= raw.length()) { sb.append(c); continue; }
            char n = raw.charAt(++i);
            switch (n) {
                case 'n': sb.append(' '); break;
                case 't': sb.append(' '); break;
                case 'r': break;
                case 'u':
                    if (i + 4 < raw.length()) {
                        try { sb.append((char) Integer.parseInt(raw.substring(i + 1, i + 5), 16)); i += 4; } catch (Exception e) {}
                    }
                    break;
                default: sb.append(n);
            }
        }
        return sb.toString().trim();
    }

    private static String buildJson(String url) {
        String ytId = youtubeId(url);
        if (ytId != null) return youtubeJson(url, ytId);
        try {
            Fetched page = fetch(url);
            if (page == null) return "{\"ok\":false}";
            Document doc = Jsoup.parse(new java.io.ByteArrayInputStream(page.body), page.charset, page.finalUrl);

            String title = firstNonEmpty(meta(doc, "og:title"), meta(doc, "twitter:title"), doc.title());
            String desc = firstNonEmpty(meta(doc, "og:description"), meta(doc, "twitter:description"), meta(doc, "description"));
            String site = firstNonEmpty(meta(doc, "og:site_name"), new URL(page.finalUrl).getHost());
            String image = absImage(doc, page.finalUrl);
            if (title.isEmpty() && desc.isEmpty()) return "{\"ok\":false}";

            return "{\"ok\":true"
                 + ",\"url\":" + js(url)
                 + ",\"title\":" + js(cut(title, 100))
                 + ",\"desc\":" + js(cut(desc, 200))
                 + ",\"site\":" + js(cut(site, 60))
                 + ",\"image\":" + js(image) + "}";
        } catch (Exception ex) {
            return "{\"ok\":false}";
        }
    }

    private static final class Fetched {
        byte[] body; String charset; String finalUrl;
    }

    private static Fetched fetch(String startUrl) throws Exception {
        String current = startUrl;
        for (int hop = 0; hop <= 3; hop++) {
            URL u = new URL(current);
            if (!isSafeTarget(u)) return null;

            HttpURLConnection conn = (HttpURLConnection) u.openConnection();
            conn.setInstanceFollowRedirects(false);
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(4000);
            conn.setRequestProperty("User-Agent", UA);
            conn.setRequestProperty("Accept", "text/html,application/xhtml+xml");
            conn.setRequestProperty("Accept-Language", "ko,en;q=0.8");
            try {
                int code = conn.getResponseCode();
                if (code >= 300 && code < 400) {
                    String loc = conn.getHeaderField("Location");
                    if (loc == null) return null;
                    current = new URL(u, loc).toString();
                    continue;
                }
                if (code != 200) return null;
                String type = conn.getContentType();
                if (type == null || !(type.toLowerCase().contains("text/html") || type.toLowerCase().contains("xhtml"))) return null;

                Fetched f = new Fetched();
                f.finalUrl = current;
                f.charset = charsetOf(type);
                try (InputStream in = conn.getInputStream()) {
                    ByteArrayOutputStream out = new ByteArrayOutputStream();
                    byte[] buf = new byte[8192];
                    int n, total = 0;
                    while ((n = in.read(buf)) != -1 && total < MAX_BYTES) {
                        int keep = Math.min(n, MAX_BYTES - total);
                        out.write(buf, 0, keep);
                        total += keep;
                    }
                    f.body = out.toByteArray();
                }
                return f;
            } finally {
                conn.disconnect();
            }
        }
        return null;
    }

    static boolean isSafeTarget(URL u) {
        try {
            String proto = u.getProtocol();
            if (!"http".equals(proto) && !"https".equals(proto)) return false;
            int port = u.getPort();
            if (port != -1 && port != 80 && port != 443) return false;
            String host = u.getHost();
            if (host == null || host.isEmpty()) return false;
            for (InetAddress a : InetAddress.getAllByName(host)) {
                if (!isPublic(a)) return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    static boolean isPublic(InetAddress a) {
        if (a.isAnyLocalAddress() || a.isLoopbackAddress() || a.isLinkLocalAddress()
                || a.isSiteLocalAddress() || a.isMulticastAddress()) return false;
        byte[] b = a.getAddress();
        if (a instanceof Inet4Address) {
            int b0 = b[0] & 0xff, b1 = b[1] & 0xff;
            if (b0 == 0 || b0 == 10 || b0 == 127) return false;
            if (b0 == 100 && b1 >= 64 && b1 <= 127) return false;     // 100.64.0.0/10 (통신사 내부망)
            if (b0 == 169 && b1 == 254) return false;                 // 링크로컬, AWS 메타데이터
            if (b0 == 172 && b1 >= 16 && b1 <= 31) return false;
            if (b0 == 192 && b1 == 168) return false;
            if (b0 == 192 && b1 == 0 && (b[2] & 0xff) == 0) return false;
            if (b0 >= 224) return false;
        } else if (a instanceof Inet6Address) {
            if ((b[0] & 0xfe) == 0xfc) return false;                  // fc00::/7 (사설)
            // ::ffff:10.0.0.1 처럼 IPv4를 감싼 주소는 안쪽 IPv4로 다시 검사
            boolean mapped = true;
            for (int i = 0; i < 10; i++) if (b[i] != 0) mapped = false;
            if (mapped && (b[10] & 0xff) == 0xff && (b[11] & 0xff) == 0xff) {
                try {
                    return isPublic(InetAddress.getByAddress(new byte[] { b[12], b[13], b[14], b[15] }));
                } catch (Exception e) { return false; }
            }
        }
        return true;
    }

    private static String charsetOf(String contentType) {
        for (String part : contentType.split(";")) {
            part = part.trim();
            if (part.toLowerCase().startsWith("charset=")) {
                String cs = part.substring(8).replace("\"", "").trim();
                try { if (java.nio.charset.Charset.isSupported(cs)) return cs; } catch (Exception e) {}
            }
        }
        return null;
    }

    private static String meta(Document doc, String key) {
        Element el = doc.selectFirst("meta[property=" + key + "], meta[name=" + key + "]");
        return el == null ? "" : el.attr("content").trim();
    }

    private static String absImage(Document doc, String base) {
        Element el = doc.selectFirst("meta[property=og:image], meta[name=og:image], meta[name=twitter:image], meta[property=twitter:image]");
        if (el == null) return "";
        try {
            String img = new URI(base).resolve(el.attr("content").trim()).toString();
            return img.startsWith("https://") && img.length() <= 1000 ? img : "";
        } catch (Exception e) {
            return "";
        }
    }

    private static String firstNonEmpty(String... values) {
        for (String v : values) if (v != null && !v.trim().isEmpty()) return v.trim().replaceAll("\\s+", " ");
        return "";
    }

    private static String cut(String s, int max) {
        return s.length() > max ? s.substring(0, max).trim() + "…" : s;
    }

    private static String js(String s) {
        if (s == null) s = "";
        StringBuilder sb = new StringBuilder(s.length() + 8).append('"');
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                case '<': sb.append("\\u003c"); break;
                case '>': sb.append("\\u003e"); break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c)); else sb.append(c);
            }
        }
        return sb.append('"').toString();
    }

    private static void fail(HttpServletResponse response, int status) throws IOException {
        response.setStatus(status);
        response.getWriter().write("{\"ok\":false}");
    }
}
