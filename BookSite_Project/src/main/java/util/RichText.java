package util;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.TextNode;
import org.jsoup.safety.Safelist;

import upload.BoardFileVO;

/** 에디터 HTML 본문 처리. 저장·출력 모두 sanitize()로 허용된 태그/속성/스타일만 남김 (저장형 XSS 방지) */
public final class RichText {
    private RichText() {}

    public static final String MARK = "<!--html-->";

    private static final Pattern UPLOAD_SRC = Pattern.compile(
            "^(?:/[A-Za-z0-9_.-]+)?/uploads/([0-9a-f]{32}\\.(?:jpg|jpeg|png|gif|bmp|webp))$");

    private static final Set<String> STYLE_PROPS = new LinkedHashSet<String>(java.util.Arrays.asList(
            "color", "background-color", "font-size", "font-weight", "font-style", "text-decoration",
            "text-align", "line-height", "width", "height", "float", "margin-left", "margin-right"));
    private static final Pattern STYLE_VALUE = Pattern.compile("^[#a-zA-Z0-9.,%()\\s-]{1,60}$");

    private static final Safelist SAFELIST = Safelist.relaxed()
            .addTags("span", "font", "hr", "s", "strike")
            .addAttributes(":all", "style")
            .addAttributes("font", "color")
            .addAttributes("img", "src", "alt", "style", "width")
            .addAttributes("a", "target")
            .removeProtocols("img", "src", "http", "https")
            .addProtocols("a", "href", "http", "https", "mailto");

    public static boolean isHtml(String content) {
        return content != null && content.startsWith(MARK);
    }

    public static String body(String content) {
        if (content == null) return "";
        return isHtml(content) ? content.substring(MARK.length()) : content;
    }

    public static String sanitize(String html) {
        if (html == null) return "";
        String cleaned = Jsoup.clean(html, "", SAFELIST, new Document.OutputSettings().prettyPrint(false));
        Document doc = Jsoup.parseBodyFragment(cleaned);
        doc.outputSettings().prettyPrint(false);

        for (Element img : doc.select("img")) {
            if (!UPLOAD_SRC.matcher(img.attr("src")).matches()) img.remove();
        }
        for (TextNode tn : collectText(doc.body())) {
            if (tn.parent() instanceof Element && ((Element) tn.parent()).closest("a") != null) continue;
            String text = tn.getWholeText();
            if (!URL.matcher(text).find()) continue;
            tn.before(linkify(HtmlUtil.esc(text)));
            tn.remove();
        }
        for (Element a : doc.select("a")) {
            a.attr("rel", "nofollow noopener noreferrer");
            if (a.hasAttr("href")) a.attr("target", "_blank"); else a.removeAttr("target");
        }
        for (Element el : doc.select("[style]")) {
            String style = cleanStyle(el.attr("style"));
            if (style.isEmpty()) el.removeAttr("style"); else el.attr("style", style);
        }
        return doc.body().html();
    }

    private static List<TextNode> collectText(Element root) {
        List<TextNode> list = new java.util.ArrayList<TextNode>();
        for (Element el : root.getAllElements()) list.addAll(el.textNodes());
        return list;
    }

    private static final Pattern URL = Pattern.compile(
            "(?:https?://|www\\.)(?:(?!&quot;|&#39;|&lt;|&gt;)[^\\s<>\"'])+", Pattern.CASE_INSENSITIVE);

    /** 텍스트 속 주소를 링크로 바꿈. ※ 반드시 HTML 이스케이프한 다음에 호출할 것 */
    public static String linkify(String escaped) {
        if (escaped == null || escaped.isEmpty()) return "";
        Matcher m = URL.matcher(escaped);
        StringBuilder sb = new StringBuilder();
        int last = 0;
        while (m.find()) {
            String url = m.group();
            String tail = "";
            while (!url.isEmpty() && ".,!?;:)]}".indexOf(url.charAt(url.length() - 1)) >= 0) {
                tail = url.charAt(url.length() - 1) + tail;
                url = url.substring(0, url.length() - 1);
            }
            String href = url.toLowerCase().startsWith("www.") ? "http://" + url : url;
            sb.append(escaped, last, m.start())
              .append("<a href=\"").append(href).append("\" target=\"_blank\" rel=\"nofollow noopener noreferrer\">")
              .append(url).append("</a>").append(tail);
            last = m.end();
        }
        return sb.append(escaped.substring(last)).toString();
    }

    public static Set<String> linkUrls(String content) {
        String html = isHtml(content) ? sanitize(body(content)) : linkify(HtmlUtil.esc(content == null ? "" : content));
        Set<String> urls = new LinkedHashSet<String>();
        for (Element a : Jsoup.parseBodyFragment(html).select("a[href]")) {
            String href = a.attr("href");
            if (href.startsWith("http://") || href.startsWith("https://")) urls.add(href);
        }
        return urls;
    }

    private static String cleanStyle(String style) {
        StringBuilder sb = new StringBuilder();
        for (String decl : style.split(";")) {
            int idx = decl.indexOf(':');
            if (idx <= 0) continue;
            String prop = decl.substring(0, idx).trim().toLowerCase();
            String value = decl.substring(idx + 1).trim();
            String lower = value.toLowerCase();
            if (!STYLE_PROPS.contains(prop)) continue;
            if (!STYLE_VALUE.matcher(value).matches()) continue;
            if (lower.contains("url") || lower.contains("expression")) continue;
            sb.append(prop).append(": ").append(value).append("; ");
        }
        return sb.toString().trim();
    }

    public static String toText(String content) {
        if (content == null) return "";
        return isHtml(content) ? Jsoup.parse(body(content)).text() : content;
    }

    public static boolean hasContent(String html) {
        Document doc = Jsoup.parseBodyFragment(html == null ? "" : html);
        return !doc.text().trim().isEmpty() || !doc.select("img").isEmpty();
    }

    public static Set<String> uploadNames(String html) {
        Set<String> names = new LinkedHashSet<String>();
        for (Element img : Jsoup.parseBodyFragment(html == null ? "" : html).select("img")) {
            Matcher m = UPLOAD_SRC.matcher(img.attr("src"));
            if (m.matches()) names.add(m.group(1));
        }
        return names;
    }

    public static String legacyToHtml(String text, List<BoardFileVO> files, String contextPath) {
        String html = HtmlUtil.esc(text == null ? "" : text);
        StringBuilder rest = new StringBuilder();
        int imgIdx = 0;
        for (BoardFileVO f : files) {
            if (!f.isImage()) continue;
            imgIdx++;
            String tag = "<img src=\"" + HtmlUtil.esc(contextPath + f.getWebPath()) + "\" alt=\"" + HtmlUtil.esc(f.getOriginalName()) + "\">";
            String placeholder = "[img" + imgIdx + "]";
            if (html.contains(placeholder)) html = html.replace(placeholder, tag);
            else rest.append("<p>").append(tag).append("</p>");
        }
        html = html.replaceAll("\\[video\\d+\\]", "");
        StringBuilder out = new StringBuilder();
        for (String line : html.split("\r?\n", -1)) {
            out.append("<p>").append(line.isEmpty() ? "<br>" : line).append("</p>");
        }
        return out.append(rest).toString();
    }
}
