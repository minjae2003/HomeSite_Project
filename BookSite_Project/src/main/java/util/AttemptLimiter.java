package util;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 실패 횟수 제한기 (서버 메모리 기반)
 *
 *  - 키(IP, 아이디 등)별로 실패 횟수를 센다.
 *  - windowMs 안에 maxFail번 실패하면 lockMs 동안 잠근다.
 *  - 세션이 아니라 서버에 기록하므로 쿠키를 지우거나 브라우저를 바꿔도 초기화되지 않는다.
 *  - 서버를 재시작하면 기록이 사라진다 (학생 프로젝트 규모에서는 충분, 서버가 여러 대면 DB/Redis로 옮겨야 함).
 */
public class AttemptLimiter {

    private static final class Entry {
        int count;
        long windowStart;
        long lockedUntil;
    }

    private final int maxFail;
    private final long windowMs;
    private final long lockMs;
    private final Map<String, Entry> map = new ConcurrentHashMap<String, Entry>();

    public AttemptLimiter(int maxFail, long windowMs, long lockMs) {
        this.maxFail = maxFail;
        this.windowMs = windowMs;
        this.lockMs = lockMs;
    }

    public int lockedMinutes(String key) {
        if (key == null) return 0;
        Entry e = map.get(key);
        if (e == null) return 0;
        synchronized (e) {
            long remain = e.lockedUntil - System.currentTimeMillis();
            return remain > 0 ? (int) Math.ceil(remain / 60000.0) : 0;
        }
    }

    public int fail(String key) {
        if (key == null) return maxFail;
        cleanupIfLarge();
        long now = System.currentTimeMillis();
        Entry e = map.computeIfAbsent(key, k -> new Entry());
        synchronized (e) {
            if (now - e.windowStart > windowMs) {
                e.windowStart = now;
                e.count = 0;
            }
            e.count++;
            if (e.count >= maxFail) {
                e.lockedUntil = now + lockMs;
                e.count = 0;
                e.windowStart = now;
                return 0;
            }
            return maxFail - e.count;
        }
    }

    public void success(String key) {
        if (key != null) map.remove(key);
    }

    /** 기록이 너무 많이 쌓이면 오래된 것 정리 (메모리 보호) */
    private void cleanupIfLarge() {
        if (map.size() < 10000) return;
        long now = System.currentTimeMillis();
        for (Iterator<Map.Entry<String, Entry>> it = map.entrySet().iterator(); it.hasNext(); ) {
            Entry e = it.next().getValue();
            synchronized (e) {
                if (e.lockedUntil < now && now - e.windowStart > windowMs) it.remove();
            }
        }
    }
}
