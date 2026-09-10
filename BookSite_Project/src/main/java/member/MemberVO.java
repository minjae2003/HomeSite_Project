package member;

import java.sql.Timestamp;

public class MemberVO {
    private String id;
    private String password;
    private String name;
    private String nickname;
    private String email;
    private String authStatus;
    private String role;
    private Timestamp regDate;

    // Standard Getters & Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAuthStatus() { return authStatus; }
    public void setAuthStatus(String authStatus) { this.authStatus = authStatus; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }

    // Legacy/JSP 호환용 Alias 메서드
    public String getPass() { return password; }
    public void setPass(String pass) { this.password = pass; }

    public Timestamp getReg_date() { return regDate; }
    public void setReg_date(Timestamp reg_date) { this.regDate = reg_date; }
}