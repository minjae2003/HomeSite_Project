package util;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

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
