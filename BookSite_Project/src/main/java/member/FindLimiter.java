package member;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import util.AttemptLimiter;

/**
 * 아이디/비밀번호 찾기 시도 제한(서버, IP 기준) + 비밀번호 재설정 허가 관리(세션 기반)
 *  - 본인 확인에 5번 실패하면 10분 동안 찾기 기능을 막음 (무작위 대입 방지)
 *  - 비밀번호 찾기 본인 확인에 성공하면 10분 동안만 그 아이디의 비밀번호를 재설정할 수 있음
 */
public class FindLimiter {
    private static final int MAX_FAIL = 5;
    private static final long LOCK_MS = 10 * 60 * 1000L;
    private static final long RESET_MS = 10 * 60 * 1000L;

    private static final String RESET_ID = "RESET_PW_ID";
    private static final String RESET_UNTIL = "RESET_PW_UNTIL";

    // 실패 횟수는 세션이 아니라 서버에 IP별로 기록 (쿠키를 지워도 초기화되지 않도록)
    private static final AttemptLimiter BY_IP = new AttemptLimiter(MAX_FAIL, LOCK_MS, LOCK_MS);

    /** 잠겨 있으면 남은 분(1 이상), 아니면 0 */
    public static int lockedMinutes(HttpServletRequest request) {
        return BY_IP.lockedMinutes(request.getRemoteAddr());
    }

    /** 실패 1회 기록, 남은 시도 횟수 반환 (0이면 방금 잠김) */
    public static int fail(HttpServletRequest request) {
        return BY_IP.fail(request.getRemoteAddr());
    }

    /** 성공해도 실패 기록은 지우지 않음 (내 정보로 한 번 성공해서 기록을 초기화한 뒤 다시 대입하는 것 방지 - 10분 지나면 자동 초기화) */
    public static void success(HttpServletRequest request) {
    }

    /** 비밀번호 재설정 허가 (본인 확인 성공 시) */
    public static void allowReset(HttpSession session, String id) {
        session.setAttribute(RESET_ID, id);
        session.setAttribute(RESET_UNTIL, System.currentTimeMillis() + RESET_MS);
    }

    /** 재설정이 허가된 아이디 (없거나 만료됐으면 null) */
    public static String resetId(HttpSession session) {
        String id = (String) session.getAttribute(RESET_ID);
        Long until = (Long) session.getAttribute(RESET_UNTIL);
        if (id == null || until == null || until < System.currentTimeMillis()) {
            clearReset(session);
            return null;
        }
        return id;
    }

    public static void clearReset(HttpSession session) {
        session.removeAttribute(RESET_ID);
        session.removeAttribute(RESET_UNTIL);
    }

    /** 아이디 일부 가리기: minjae2003 → min******* */
    public static String mask(String id) {
        if (id == null || id.isEmpty()) return "";
        int keep = Math.max(1, id.length() / 3);
        if (id.length() <= 2) keep = 1;
        StringBuilder sb = new StringBuilder(id.substring(0, keep));
        for (int i = keep; i < id.length(); i++) sb.append('*');
        return sb.toString();
    }
}