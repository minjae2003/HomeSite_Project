package mypage;

/**
 * 활동 점수 → 등급 계산
 *  점수 = 작성글 x 10 + 작성댓글 x 2 + 받은 추천 x 5
 *  (기준표는 THRESHOLDS / NAMES 배열만 바꾸면 조정 가능)
 */
public class Level {
    private static final int[] THRESHOLDS = { 0, 30, 80, 150, 300, 500, 800 };
    private static final String[] NAMES = { "자취새내기", "자취입문", "자취러", "살림꾼", "살림고수", "자취달인", "자취의 품격" };

    private final int point;
    private final int index;

    public Level(int posts, int comments, int receivedLikes) {
        this.point = posts * 10 + comments * 2 + receivedLikes * 5;
        int idx = 0;
        for (int i = 0; i < THRESHOLDS.length; i++) {
            if (point >= THRESHOLDS[i]) idx = i;
        }
        this.index = idx;
    }

    public int getPoint() { return point; }
    public int getLevel() { return index + 1; }
    public String getName() { return NAMES[index]; }
    public boolean isMax() { return index == THRESHOLDS.length - 1; }

    public int getNextLevel() { return isMax() ? getLevel() : getLevel() + 1; }
    public String getNextName() { return isMax() ? getName() : NAMES[index + 1]; }

    /** 다음 등급까지 남은 점수 */
    public int getRemain() { return isMax() ? 0 : THRESHOLDS[index + 1] - point; }

    /** 현재 등급 구간 안에서의 진행률 (0~100) */
    public int getPercent() {
        if (isMax()) return 100;
        int from = THRESHOLDS[index], to = THRESHOLDS[index + 1];
        return (int) Math.round((point - from) * 100.0 / (to - from));
    }
}
