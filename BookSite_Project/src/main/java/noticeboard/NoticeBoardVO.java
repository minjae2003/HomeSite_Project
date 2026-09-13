package noticeboard;

import java.sql.Timestamp;

public class NoticeBoardVO {
	private int num;
    private String writer;
    private String writerId;
    private String writerNickname;
    private String subject;
    private String content;
    private int readcount;
    private int likeCount;
    private Timestamp regDate;
    private String category; // board_type (FREE, TIP, QNA, NOTICE 등)
    private int commentCount;

    // Getters & Setters
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
}
