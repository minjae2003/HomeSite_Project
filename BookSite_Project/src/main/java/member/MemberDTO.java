package member;

import java.sql.Timestamp;

public class MemberDTO {
    private String id;
    private String pass;
    private String name;
    private Timestamp reg_date;

    // 기본 생성자
    public MemberDTO() {}

    // 필드 생성자
    public MemberDTO(String id, String pass, String name, Timestamp reg_date) {
        this.id = id;
        this.pass = pass;
        this.name = name;
        this.reg_date = reg_date;
    }

    // Getter & Setter
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPass() {
        return pass;
    }

    public void setPass(String pass) {
        this.pass = pass;
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