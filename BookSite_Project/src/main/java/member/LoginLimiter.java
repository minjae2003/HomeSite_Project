package member;

import javax.servlet.http.HttpServletRequest;
import util.AttemptLimiter;

/**
 * 비밀번호 확인 시도 제한 (로그인 / 회원정보 수정 / 회원 탈퇴의 현재 비밀번호 확인에 공통 사용)
 *
 *  - 아이디별: 15분 안에 5번 틀리면 그 아이디는 10분 잠김 (한 계정을 집중 공격하는 것 방지)
 *  - IP별:    15분 안에 20번 틀리면 그 IP는 15분 잠김 (여러 아이디를 돌아가며 시도하는 것 방지)
 *
 *  ※ 아이디 존재 여부와 상관없이 똑같이 세므로, 잠금 메시지로 아이디가 있는지 알아낼 수 없다.
 */
public final class LoginLimiter {
    private LoginLimiter() {}

    private static final long MIN = 60 * 1000L;
    private static final AttemptLimiter BY_ID = new AttemptLimiter(5, 15 * MIN, 10 * MIN);
    private static final AttemptLimiter BY_IP = new AttemptLimiter(20, 15 * MIN, 15 * MIN);

    private static String idKey(String id) {
        return id == null ? null : id.trim().toLowerCase();
    }

    /** 잠겨 있으면 남은 분, 아니면 0 */
    public static int lockedMinutes(HttpServletRequest request, String id) {
        return Math.max(BY_IP.lockedMinutes(request.getRemoteAddr()), BY_ID.lockedMinutes(idKey(id)));
    }

    /** 실패 기록. 이 아이디의 남은 시도 횟수 반환 (0이면 잠김) */
    public static int fail(HttpServletRequest request, String id) {
        int ipLeft = BY_IP.fail(request.getRemoteAddr());
        int idLeft = BY_ID.fail(idKey(id));
        return Math.min(ipLeft, idLeft);
    }

    public static void success(HttpServletRequest request, String id) {
        BY_ID.success(idKey(id));
        // IP 기록은 지우지 않음 (한 계정 로그인 성공으로 다른 계정 대입 기록이 사라지지 않도록)
    }
}
