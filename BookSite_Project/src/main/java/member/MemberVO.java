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
    private String phone;

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    private Timestamp pwChangedAt;
    private Timestamp infoChangedAt;

    public Timestamp getPwChangedAt() { return pwChangedAt; }
    public void setPwChangedAt(Timestamp pwChangedAt) { this.pwChangedAt = pwChangedAt; }

    public Timestamp getInfoChangedAt() { return infoChangedAt; }
    public void setInfoChangedAt(Timestamp infoChangedAt) { this.infoChangedAt = infoChangedAt; }
    
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

    public String getPass() { return password; }
    public void setPass(String pass) { this.password = pass; }

    public Timestamp getReg_date() { return regDate; }
    public void setReg_date(Timestamp reg_date) { this.regDate = reg_date; }

    private Timestamp suspendUntil;
    private String suspendReason;
    private int postCount;
    private int commentCount;

    public Timestamp getSuspendUntil() { return suspendUntil; }
    public void setSuspendUntil(Timestamp suspendUntil) { this.suspendUntil = suspendUntil; }
    public String getSuspendReason() { return suspendReason; }
    public void setSuspendReason(String suspendReason) { this.suspendReason = suspendReason; }
    public int getPostCount() { return postCount; }
    public void setPostCount(int postCount) { this.postCount = postCount; }
    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }

    /** 지금 이용 정지 상태인지 */
    public boolean isSuspended() { return suspendUntil != null && suspendUntil.getTime() > System.currentTimeMillis(); }
    /** 정지 종료일 표시 (영구 정지는 9999년으로 저장) */
    public String getSuspendUntilText() {
        if (suspendUntil == null) return "";
        if (suspendUntil.toLocalDateTime().getYear() >= 9999) return "영구";
        return new java.text.SimpleDateFormat("yyyy.MM.dd HH:mm").format(suspendUntil) + "까지";
    }
}
