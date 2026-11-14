package member;

import javax.servlet.http.HttpServletRequest;
import util.AttemptLimiter;

/**
 * 비밀번호 확인 시도 제한: 아이디별 15분 5회 실패 → 10분 잠금, IP별 15분 20회 실패 → 15분 잠금 (무작위 대입 방지)
 * ※ 아이디 존재 여부와 상관없이 똑같이 세므로 잠금 메시지로 아이디 존재 여부를 알 수 없음
 */
public final class LoginLimiter {
    private LoginLimiter() {}

    private static final long MIN = 60 * 1000L;
    private static final AttemptLimiter BY_ID = new AttemptLimiter(5, 15 * MIN, 10 * MIN);
    private static final AttemptLimiter BY_IP = new AttemptLimiter(20, 15 * MIN, 15 * MIN);

    private static String idKey(String id) {
        return id == null ? null : id.trim().toLowerCase();
    }

    public static int lockedMinutes(HttpServletRequest request, String id) {
        return Math.max(BY_IP.lockedMinutes(util.ClientIp.get(request)), BY_ID.lockedMinutes(idKey(id)));
    }

    public static int fail(HttpServletRequest request, String id) {
        int ipLeft = BY_IP.fail(util.ClientIp.get(request));
        int idLeft = BY_ID.fail(idKey(id));
        return Math.min(ipLeft, idLeft);
    }

    public static void success(HttpServletRequest request, String id) {
        BY_ID.success(idKey(id));
        // IP 기록은 지우지 않음 (한 계정 로그인 성공으로 다른 계정 대입 기록이 사라지지 않도록)
    }
}
