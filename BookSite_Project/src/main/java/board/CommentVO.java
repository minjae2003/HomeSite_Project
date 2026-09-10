package board;

import java.sql.Timestamp;

public class CommentVO {
    private int commentNum;
    private int boardNum;
    private String writer;
    private String writerId;
    private String writerNickname;
    private String content;
    private Timestamp regDate;

    public int getCommentNum() { return commentNum; }
    public void setCommentNum(int commentNum) { this.commentNum = commentNum; }

    public int getBoardNum() { return boardNum; }
    public void setBoardNum(int boardNum) { this.boardNum = boardNum; }

    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }

    public String getWriterId() { return writerId; }
    public void setWriterId(String writerId) { this.writerId = writerId; }

    public String getWriterNickname() { return writerNickname; }
    public void setWriterNickname(String writerNickname) { this.writerNickname = writerNickname; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
}