package board;

import java.sql.Timestamp;

public class BoardVO {
    private int num;
    private String boardType;
    private String category;
    private String writerId;
    private String writerNickname;
    private String subject;
    private String content;
    private int readcount;
    private int likeCount;
    private Timestamp regDate;

    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; }
    public String getBoardType() { return boardType; }
    public void setBoardType(String boardType) { this.boardType = boardType; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getWriterId() { return writerId; }
    public void setWriterId(String writerId) { this.writerId = writerId; }
    public String getWriterNickname() { return writerNickname; }
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
}