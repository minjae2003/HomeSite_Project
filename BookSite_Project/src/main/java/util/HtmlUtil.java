package util;

/**
 * XSS 방지용 출력 이스케이프 유틸
 *
 *  - esc(s) : HTML 본문 / 속성값(value="...") 안에 넣을 때
 *             예) <%= HtmlUtil.esc(article.getSubject()) %>
 *  - js(s)  : <script> 안의 '...' 또는 "..." 문자열 안에 넣을 때
 *             예) alert('<%= HtmlUtil.js(nickname) %>님 환영합니다');
 *
 * 사용자가 입력한 값(제목, 본문, 댓글, 닉네임, 파일명 등)은 화면에 찍기 직전에 반드시 둘 중 하나를 거친다.
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
                case '<':  sb.append("\\u003C"); break;   // </script> 로 스크립트 블록을 끊는 것 방지
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
