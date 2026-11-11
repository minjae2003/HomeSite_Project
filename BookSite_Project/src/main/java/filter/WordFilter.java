package filter;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;

/**
 * 금칙어 검사.
 *  - 띄어쓰기·숫자·특수문자를 끼워 넣은 우회 표현도 찾음 (예: "시 발", "시1발", "시.발")
 *    단, 그렇게 떨어진 경우는 앞뒤가 다른 글자와 붙어 있지 않을 때만 금칙어로 봄 ("다시 발견" 같은 오탐 방지)
 *  - 예외 단어(ALLOW)에 속한 부분은 검사하지 않음 (예: "시발점")
 *  - 목록은 1분마다 DB에서 다시 읽음. DB 오류 시에는 마지막 목록으로 검사(처음부터 없으면 검사 안 함)
 */
public final class WordFilter {
    private WordFilter() {}

    private static final long RELOAD_MS = 60_000;
    private static volatile List<String[]> ban = new ArrayList<String[]>();   // {원래 단어, 정규화한 단어}
    private static volatile List<String> allow = new ArrayList<String>();
    private static volatile long loadedAt = 0;

    /** 관리자 화면에서 목록을 바꾼 직후 바로 반영되게 */
    public static void invalidate() { loadedAt = 0; }

    private static void reloadIfNeeded() {
        if (System.currentTimeMillis() - loadedAt < RELOAD_MS) return;
        synchronized (WordFilter.class) {
            if (System.currentTimeMillis() - loadedAt < RELOAD_MS) return;
            List<BannedWordDAO.Word> words = BannedWordDAO.getInstance().list();
            loadedAt = System.currentTimeMillis();
            if (words == null) return;
            List<String[]> b = new ArrayList<String[]>();
            List<String> a = new ArrayList<String>();
            for (BannedWordDAO.Word w : words) {
                String n = letters(w.word);
                if (n.isEmpty()) continue;
                if ("ALLOW".equals(w.type)) a.add(n); else b.add(new String[] { w.word, n });
            }
            ban = b;
            allow = a;
        }
    }

    /** 글자(한글·자모·영문 등)만 남기고 소문자로 */
    static String letters(String s) {
        StringBuilder sb = new StringBuilder();
        String t = Normalizer.normalize(s == null ? "" : s, Normalizer.Form.NFKC).toLowerCase();
        for (int i = 0; i < t.length(); i++) if (Character.isLetter(t.charAt(i))) sb.append(t.charAt(i));
        return sb.toString();
    }

    /** 금칙어가 있으면 그 단어, 없으면 null */
    public static String find(String text) {
        if (text == null || text.isEmpty()) return null;
        reloadIfNeeded();
        return find(text, ban, allow);
    }

    static String find(String text, List<String[]> banList, List<String> allowList) {
        if (banList.isEmpty()) return null;
        String s = Normalizer.normalize(text, Normalizer.Form.NFKC).toLowerCase();

        // 글자만 이어 붙인 문자열 + 각 글자의 원래 위치
        int n = s.length();
        StringBuilder ls = new StringBuilder(n);
        int[] pos = new int[n];
        for (int i = 0; i < n; i++) {
            if (Character.isLetter(s.charAt(i))) { pos[ls.length()] = i; ls.append(s.charAt(i)); }
        }
        String L = ls.toString();

        // 예외 단어가 차지하는 위치 표시
        boolean[] allowed = new boolean[L.length()];
        for (String a : allowList) {
            for (int i = L.indexOf(a); i >= 0; i = L.indexOf(a, i + 1)) {
                for (int k = i; k < i + a.length(); k++) allowed[k] = true;
            }
        }

        for (String[] w : banList) {
            String word = w[1];
            for (int i = L.indexOf(word); i >= 0; i = L.indexOf(word, i + 1)) {
                int j = i + word.length() - 1;
                boolean skip = false;
                for (int k = i; k <= j; k++) if (allowed[k]) { skip = true; break; }
                if (skip) continue;
                int start = pos[i], end = pos[j];
                if (end - start == j - i) return w[0];               // 원문에서도 붙어 있음
                // 사이에 공백·숫자·기호가 끼어 있음 → 앞뒤가 다른 글자와 붙어 있지 않을 때만
                boolean leftOk = start == 0 || !Character.isLetter(s.charAt(start - 1));
                boolean rightOk = end == n - 1 || !Character.isLetter(s.charAt(end + 1));
                if (leftOk && rightOk) return w[0];
            }
        }
        return null;
    }

    /** 사용자에게 보여줄 안내 (단어는 첫 글자만 보여줌) */
    public static String message(String word) {
        String masked = word.length() <= 1 ? "*" : word.charAt(0) + "*".repeat(word.length() - 1);
        return "부적절한 표현(" + masked + ")이 포함되어 있어요. 운영정책을 확인하고 수정해 주세요.";
    }
}
