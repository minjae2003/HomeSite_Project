package replyfreeboard;

import java.sql.Timestamp;

public class ReplyfreeboardVO {

    private int rnum;
    private String rwriter;
    private String reply;
    private Timestamp rreg_date;
    private int ref;

    public int getRnum() {
        return rnum;
    }

    public void setRnum(int rnum) {
        this.rnum = rnum;
    }

    public String getRwriter() {
        return rwriter;
    }

    public void setRwriter(String rwriter) {
        this.rwriter = rwriter;
    }

    public String getReply() {
        return reply;
    }

    public void setReply(String reply) {
        this.reply = reply;
    }

    public Timestamp getRreg_date() {
        return rreg_date;
    }

    public void setRreg_date(Timestamp rreg_date) {
        this.rreg_date = rreg_date;
    }

    public int getRef() {
        return ref;
    }

    public void setRef(int ref) {
        this.ref = ref;
    }
}