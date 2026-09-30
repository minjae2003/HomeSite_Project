package member;

import javax.servlet.http.HttpSession;

/**
 * 아이디/비밀번호 찾기 시도 제한 + 비밀번호 재설정 허가 관리 (세션 기반)
 *  - 본인 확인에 5번 실패하면 10분 동안 찾기 기능을 막음 (무작위 대입 방지)
 *  - 비밀번호 찾기 본인 확인에 성공하면 10분 동안만 그 아이디의 비밀번호를 재설정할 수 있음
 */
public class FindLimiter {
    private static final int MAX_FAIL = 5;
    private static final long LOCK_MS = 10 * 60 * 1000L;
    private static final long RESET_MS = 10 * 60 * 1000L;

    private static final String FAIL = "FIND_FAIL_COUNT";
    private static final String LOCK_UNTIL = "FIND_LOCK_UNTIL";
    private static final String RESET_ID = "RESET_PW_ID";
    private static final String RESET_UNTIL = "RESET_PW_UNTIL";

    /** 잠겨 있으면 남은 분(1 이상), 아니면 0 */
    public static int lockedMinutes(HttpSession session) {
        Long until = (Long) session.getAttribute(LOCK_UNTIL);
        if (until == null) return 0;
        long remain = until - System.currentTimeMillis();
        if (remain <= 0) {
            session.removeAttribute(LOCK_UNTIL);
            session.removeAttribute(FAIL);
            return 0;
        }
        return (int) Math.ceil(remain / 60000.0);
    }

    /** 실패 1회 기록, 남은 시도 횟수 반환 (0이면 방금 잠김) */
    public static int fail(HttpSession session) {
        Integer cnt = (Integer) session.getAttribute(FAIL);
        cnt = (cnt == null ? 0 : cnt) + 1;
        if (cnt >= MAX_FAIL) {
            session.setAttribute(LOCK_UNTIL, System.currentTimeMillis() + LOCK_MS);
            session.setAttribute(FAIL, 0);
            return 0;
        }
        session.setAttribute(FAIL, cnt);
        return MAX_FAIL - cnt;
    }

    public static void success(HttpSession session) {
        session.removeAttribute(FAIL);
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