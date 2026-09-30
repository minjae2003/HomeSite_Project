package notification;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * 알림 1건 (NOTIFICATION 테이블)
 *  type: COMMENT(내 글에 댓글) / LIKE(내 글 추천) / NOTICE(새 공지사항)
 */
public class NotificationVO {
    private int notiNum;
    private String receiverId;
    private String type;
    private String actorId;
    private String actorNickname;
    private int boardNum;
    private String boardSubject;
    private String preview;     // 댓글 내용 / 공지 본문 미리보기
    private String boardType;   // 조회 시 BOARD와 조인해서 채움 (링크 경로 결정용)
    private boolean read;
    private Timestamp regDate;

    public int getNotiNum() { return notiNum; }
    public void setNotiNum(int notiNum) { this.notiNum = notiNum; }

    public String getReceiverId() { return receiverId; }
    public void setReceiverId(String receiverId) { this.receiverId = receiverId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getActorId() { return actorId; }
    public void setActorId(String actorId) { this.actorId = actorId; }

    public String getActorNickname() { return actorNickname != null ? actorNickname : actorId; }
    public void setActorNickname(String actorNickname) { this.actorNickname = actorNickname; }

    public int getBoardNum() { return boardNum; }
    public void setBoardNum(int boardNum) { this.boardNum = boardNum; }

    public String getBoardSubject() { return boardSubject != null ? boardSubject : ""; }
    public void setBoardSubject(String boardSubject) { this.boardSubject = boardSubject; }

    public String getPreview() { return preview; }
    public void setPreview(String preview) { this.preview = preview; }

    public String getBoardType() { return boardType; }
    public void setBoardType(String boardType) { this.boardType = boardType; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }

    /** 알림을 눌렀을 때 이동할 게시글 경로 (contextPath 뒤에 붙임) */
    public String getLinkPath() {
        String folder = "NOTICE".equals(boardType) ? "noticeboard" : "freeboard";
        return "/" + folder + "/content.jsp?num=" + boardNum;
    }

    /** 헤더 드롭다운용 한 줄 문구 (HTML, 사용자 입력값은 모두 이스케이프됨) */
    public String getMessageHtml() {
        String nick = "<b>" + esc(getActorNickname()) + "</b>";
        String subj = "\"" + esc(shorten(getBoardSubject(), 24)) + "\"";
        if ("COMMENT".equals(type)) return nick + "님이 내 글 " + subj + "에 댓글을 남겼어요";
        if ("LIKE".equals(type)) return nick + "님이 내 글 " + subj + "을(를) 추천했어요";
        if ("NOTICE".equals(type)) return "새 공지사항 <b>" + esc(shorten(getBoardSubject(), 30)) + "</b>이(가) 등록됐어요";
        return esc(getBoardSubject());
    }

    /** 전체 알림 페이지용 제목 (HTML) */
    public String getTitleHtml() {
        String nick = "<b>" + esc(getActorNickname()) + "</b>";
        String subj = "\"" + esc(shorten(getBoardSubject(), 40)) + "\"";
        if ("COMMENT".equals(type)) return nick + "님이 내 글 " + subj + "에 댓글을 남겼어요";
        if ("LIKE".equals(type)) return nick + "님이 내 글 <b>" + subj + "</b>을(를) 추천했어요";
        if ("NOTICE".equals(type)) return esc(getBoardSubject());
        return esc(getBoardSubject());
    }

    /** 전체 알림 페이지용 부가 설명 (댓글 내용 / 공지 본문 미리보기), 없으면 null */
    public String getDescHtml() {
        if (preview == null || preview.trim().isEmpty()) return null;
        String p = esc(shorten(preview.trim(), 60));
        return "COMMENT".equals(type) ? "\"" + p + "\"" : p;
    }

    /** "5분 전", "어제" 같은 상대 시간 (헤더 드롭다운용) */
    public String getTimeAgo() {
        if (regDate == null) return "";
        long diffSec = (System.currentTimeMillis() - regDate.getTime()) / 1000;
        if (diffSec < 60) return "방금 전";
        if (diffSec < 3600) return (diffSec / 60) + "분 전";
        if (diffSec < 86400) return (diffSec / 3600) + "시간 전";
        if (diffSec < 86400 * 2) return "어제";
        if (diffSec < 86400 * 7) return (diffSec / 86400) + "일 전";
        return new SimpleDateFormat("yyyy.MM.dd").format(regDate);
    }

    /** 전체 알림 페이지용 시간: 오늘 → "5분 전", 어제 → "어제 18:12", 그 외 → "09.14" */
    public String getTimeText() {
        if (regDate == null) return "";
        int days = daysAgo();
        if (days <= 0) return getTimeAgo();
        if (days == 1) return "어제 " + new SimpleDateFormat("HH:mm").format(regDate);
        Calendar now = Calendar.getInstance(), c = Calendar.getInstance();
        c.setTime(regDate);
        return new SimpleDateFormat(now.get(Calendar.YEAR) == c.get(Calendar.YEAR) ? "MM.dd" : "yyyy.MM.dd").format(regDate);
    }

    /** 날짜 묶음 이름: 오늘 / 어제 / 이번 주 / 이전 알림 */
    public String getGroupLabel() {
        int days = daysAgo();
        if (days <= 0) return "오늘";
        if (days == 1) return "어제";
        if (days < 7) return "이번 주";
        return "이전 알림";
    }

    /** 오늘 기준 며칠 전인지 (날짜 단위) */
    private int daysAgo() {
        if (regDate == null) return 0;
        Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR_OF_DAY, 0); today.set(Calendar.MINUTE, 0);
        today.set(Calendar.SECOND, 0); today.set(Calendar.MILLISECOND, 0);
        Calendar d = Calendar.getInstance();
        d.setTime(regDate);
        d.set(Calendar.HOUR_OF_DAY, 0); d.set(Calendar.MINUTE, 0);
        d.set(Calendar.SECOND, 0); d.set(Calendar.MILLISECOND, 0);
        return (int) Math.round((today.getTimeInMillis() - d.getTimeInMillis()) / 86400000.0);
    }

    /** 알림 종류별 아이콘 */
    public String getIcon() {
        if ("COMMENT".equals(type)) return "💬";
        if ("LIKE".equals(type)) return "👍";
        if ("NOTICE".equals(type)) return "📢";
        return "🔔";
    }

    private static String shorten(String s, int max) {
        if (s == null) return "";
        return s.length() > max ? s.substring(0, max) + "…" : s;
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}