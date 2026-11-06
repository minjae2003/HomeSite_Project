package board;

import java.sql.Timestamp;

public class BoardVO {
    private int num;
    private String writer;
    private String writerId;
    private String writerNickname;
    private String subject;
    private String content;
    private int readcount;
    private int likeCount;
    private Timestamp regDate;
    private String category;
    private int commentCount;

    // DB의 category 컬럼에 매핑되는 값. 자유게시판에서는 쓰지 않고,
    // 공지게시판(board_type='NOTICE')에서만 FIX(고정공지)/NORMAL(일반공지) 구분에 사용.
    private String noticeType;

    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; }

    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }

    public String getWriterId() { return writerId; }
    public void setWriterId(String writerId) { this.writerId = writerId; }

    public String getWriterNickname() { return writerNickname != null ? writerNickname : writer; }
    public void setWriterNickname(String writerNickname) { this.writerNickname = writerNickname; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getReadcount() { return readcount; }
    public void setReadcount(int readcount) { this.readcount = readcount; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }

    public String getCategory() { return category != null ? category : "FREE"; }
    public void setCategory(String category) { this.category = category; }

    public int getCommentCount() {
        return commentCount;
    }
    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
    }

    public String getNoticeType() { return noticeType != null ? noticeType : "NORMAL"; }
    public void setNoticeType(String noticeType) { this.noticeType = noticeType; }
    /** 자유게시판 글이 관리자에 의해 상단 고정됐는지 (category 컬럼 = FIX) */
    public boolean isPinned() { return "FIX".equals(noticeType); }
}