package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/** CSRF 방지 토큰: 폼은 hidden 필드(_csrf), AJAX는 X-CSRF-Token 헤더로 전송 */
public final class CsrfUtil {
    private CsrfUtil() {}

    public static final String PARAM = "_csrf";
    public static final String HEADER = "X-CSRF-Token";
    private static final String SESSION_KEY = "CSRF_TOKEN";
    private static final SecureRandom RANDOM = new SecureRandom();

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
