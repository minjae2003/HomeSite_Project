package member;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import util.AttemptLimiter;

/** 아이디/비밀번호 찾기 시도 제한 (IP 기준, 무작위 대입 방지) + 비밀번호 재설정 허가 관리 (세션, 10분) */
public class FindLimiter {
    private static final int MAX_FAIL = 5;
    private static final long LOCK_MS = 10 * 60 * 1000L;
    private static final long RESET_MS = 10 * 60 * 1000L;

    private static final String RESET_ID = "RESET_PW_ID";
    private static final String RESET_UNTIL = "RESET_PW_UNTIL";

    private static final AttemptLimiter BY_IP = new AttemptLimiter(MAX_FAIL, LOCK_MS, LOCK_MS);

    public static int lockedMinutes(HttpServletRequest request) {
        return BY_IP.lockedMinutes(request.getRemoteAddr());
    }

    public static int fail(HttpServletRequest request) {
        return BY_IP.fail(request.getRemoteAddr());
    }

    /** 성공해도 실패 기록은 지우지 않음 (내 정보로 한 번 성공해서 기록을 초기화한 뒤 다시 대입하는 것 방지 - 10분 지나면 자동 초기화) */
    public static void success(HttpServletRequest request) {
    }

    public static void allowReset(HttpSession session, String id) {
        session.setAttribute(RESET_ID, id);
        session.setAttribute(RESET_UNTIL, System.currentTimeMillis() + RESET_MS);
    }

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

    public static String mask(String id) {
        if (id == null || id.isEmpty()) return "";
        int keep = Math.max(1, id.length() / 3);
        if (id.length() <= 2) keep = 1;
        StringBuilder sb = new StringBuilder(id.substring(0, keep));
        for (int i = keep; i < id.length(); i++) sb.append('*');
        return sb.toString();
    }
}