package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * CSRF(사이트 간 요청 위조) 방지 토큰
 *
 *  - 세션마다 추측할 수 없는 랜덤 토큰을 하나 만들어 두고,
 *  - 우리 사이트의 POST 폼에는 hidden 필드로 토큰을 넣는다.
 *      <input type="hidden" name="_csrf" value="<%= util.CsrfUtil.token(session) %>">
 *  - fetch 요청은 헤더로 보낸다.   headers: { 'X-CSRF-Token': '...' }
 *  - CsrfFilter가 모든 POST 요청에서 토큰이 세션 값과 같은지 검사한다.
 *
 *  다른 사이트는 이 토큰 값을 읽을 수 없으므로, 거기서 몰래 보낸 요청은 거부된다.
 */
public final class CsrfUtil {
    private CsrfUtil() {}

    public static final String PARAM = "_csrf";
    public static final String HEADER = "X-CSRF-Token";
    private static final String SESSION_KEY = "CSRF_TOKEN";
    private static final SecureRandom RANDOM = new SecureRandom();

    /** 이 세션의 토큰 (없으면 새로 만듦). Base64 URL-safe 문자만 들어 있어 HTML/JS에 그대로 넣어도 안전 */
    public static String token(HttpSession session) {
        String t = (String) session.getAttribute(SESSION_KEY);
        if (t == null) {
            byte[] b = new byte[32];
            RANDOM.nextBytes(b);
            t = Base64.getUrlEncoder().withoutPadding().encodeToString(b);
            session.setAttribute(SESSION_KEY, t);
        }
        return t;
    }

    /** 요청에 담긴 토큰(헤더 또는 _csrf 파라미터)이 세션 토큰과 같은지 */
    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String expected = (String) session.getAttribute(SESSION_KEY);
        if (expected == null) return false;

        String actual = request.getHeader(HEADER);
        if (actual == null || actual.isEmpty()) actual = request.getParameter(PARAM);
        if (actual == null) return false;

        return MessageDigest.isEqual(expected.getBytes(StandardCharsets.UTF_8),
                                     actual.getBytes(StandardCharsets.UTF_8));
    }
}
