package member;

import java.sql.Timestamp;

public class MemberVO {
    private String id;
    private String pass;
    private String name;
    private Timestamp reg_date;

    public MemberVO() {}

    public MemberVO(String id, String pass, String name, Timestamp reg_date) {
        this.id = id;
        this.pass = pass;
        this.name = name;
        this.reg_date = reg_date;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    /* pass 필드용 Getter / Setter */
    public String getPass() {
        return pass;
    }

    public void setPass(String pass) {
        this.pass = pass;
    }

    /* MemberDAO.java의 getPasswd() 에러 해결용 호환 메서드 */
    public String getPasswd() {
        return pass;
    }

    public void setPasswd(String passwd) {
        this.pass = passwd;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Timestamp getReg_date() {
        return reg_date;
    }

    public void setReg_date(Timestamp reg_date) {
        this.reg_date = reg_date;
    }
}