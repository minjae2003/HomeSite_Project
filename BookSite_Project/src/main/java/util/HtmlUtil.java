package util;

/**
 * XSS 방지용 출력 이스케이프: esc()는 HTML 본문·속성값, js()는 <script> 안 문자열.
 * ※ 사용자 입력값은 화면에 찍기 전에 반드시 둘 중 하나를 거칠 것
 */
public final class HtmlUtil {
    private HtmlUtil() {}

    public static String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '&':  sb.append("&amp;");  break;
                case '<':  sb.append("&lt;");   break;
                case '>':  sb.append("&gt;");   break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#39;");  break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }

    public static String js(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '\'': sb.append("\\'");  break;
                case '"':  sb.append("\\\""); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '<':  sb.append("\\u003C"); break;
                case '>':  sb.append("\\u003E"); break;
                case '&':  sb.append("\\u0026"); break;
                case ' ': sb.append("\\u2028"); break;
                case ' ': sb.append("\\u2029"); break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }
}
