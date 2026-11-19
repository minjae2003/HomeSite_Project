package member;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpServletRequest;

import util.AttemptLimiter;

/**
 * 아이디/비밀번호 찾기 요청 제한.
 * - IP당: 10분에 5번까지 요청 (가입 여부를 알아내려는 대입 방지)
 * - 이메일 주소당: 1시간에 3통까지 발송 (남의 메일함에 폭탄 발송 방지)
 */
public class FindLimiter {
    private static final AttemptLimiter BY_IP = new AttemptLimiter(5, 10 * 60 * 1000L, 10 * 60 * 1000L);

    private static final int MAIL_MAX = 3;
    private static final long MAIL_WINDOW = 60 * 60 * 1000L;
    private static final Map<String, long[]> MAIL = new ConcurrentHashMap<String, long[]>();

    public static int lockedMinutes(HttpServletRequest request) {
        return BY_IP.lockedMinutes(util.ClientIp.get(request));
    }

    /** 요청 한 번을 기록 (성공·실패와 상관없이 셈) */
    public static void count(HttpServletRequest request) {
        BY_IP.fail(util.ClientIp.get(request));
    }

    /** 이 주소로 메일을 더 보내도 되면 true (보낸 것으로 기록) */
    public static boolean takeMail(String email) {
        String key = email.trim().toLowerCase();
        long now = System.currentTimeMillis();
        if (MAIL.size() > 10000) {
            for (Iterator<long[]> it = MAIL.values().iterator(); it.hasNext(); ) {
                if (now - it.next()[0] > MAIL_WINDOW) it.remove();
            }
        }
        long[] e = MAIL.computeIfAbsent(key, k -> new long[] { now, 0 });
        synchronized (e) {
            if (now - e[0] > MAIL_WINDOW) { e[0] = now; e[1] = 0; }
            if (e[1] >= MAIL_MAX) return false;
            e[1]++;
            return true;
        }
    }

    public static String mask(String id) {
        if (id == null || id.isEmpty()) return "";
        int keep = Math.max(1, id.length() / 3);
        if (id.length() <= 2) keep = 1;
        StringBuilder sb = new StringBuilder(id.substring(0, keep));
        for (int i = keep; i < id.length(); i++) sb.append('*');
        return sb.toString();
    }
}
