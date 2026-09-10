package reply;

import java.sql.Timestamp;

public class ReplyVO {
    private int replyNum;
    private int boardNum;
    private String writerId;
    private String writerNickname;
    private String content;
    private Timestamp regDate;

    public int getReplyNum() { return replyNum; }
    public void setReplyNum(int replyNum) { this.replyNum = replyNum; }
    public int getBoardNum() { return boardNum; }
    public void setBoardNum(int boardNum) { this.boardNum = boardNum; }
    public String getWriterId() { return writerId; }
    public void setWriterId(String writerId) { this.writerId = writerId; }
    public String getWriterNickname() { return writerNickname; }
    public void setWriterNickname(String writerNickname) { this.writerNickname = writerNickname; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
}