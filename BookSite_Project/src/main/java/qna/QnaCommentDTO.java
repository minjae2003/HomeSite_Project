package qna;

import java.sql.Timestamp;

public class QnaCommentDTO {
    private int c_num;
    private int num;
    private String writer;
    private String content;
    private Timestamp reg_date;

    public int getC_num() { return c_num; }
    public void setC_num(int c_num) { this.c_num = c_num; }

    public int getNum() { return num; }
    public void setNum(int num) { this.num = num; }

    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getReg_date() { return reg_date; }
    public void setReg_date(Timestamp reg_date) { this.reg_date = reg_date; }
}