package inquiry;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class InquiryVO {
    private int inquiryNum;
    private String userId;
    private String userNickname;
    private String category;
    private String subject;
    private String content;
    private String pageUrl;
    private String status;
    private String answer;
    private String answeredBy;
    private Timestamp answeredAt;
    private Timestamp regDate;

    public int getInquiryNum() { return inquiryNum; }
    public void setInquiryNum(int inquiryNum) { this.inquiryNum = inquiryNum; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getUserNickname() { return userNickname != null ? userNickname : userId; }
    public void setUserNickname(String userNickname) { this.userNickname = userNickname; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getPageUrl() { return pageUrl; }
    public void setPageUrl(String pageUrl) { this.pageUrl = pageUrl; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    public String getAnsweredBy() { return answeredBy; }
    public void setAnsweredBy(String answeredBy) { this.answeredBy = answeredBy; }
    public Timestamp getAnsweredAt() { return answeredAt; }
    public void setAnsweredAt(Timestamp answeredAt) { this.answeredAt = answeredAt; }
    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }

    public boolean isDone() { return "DONE".equals(status); }
    public String getCategoryName() { return InquiryDAO.categoryName(category); }

    public String getRegDateText() {
        return regDate == null ? "" : new SimpleDateFormat("yyyy.MM.dd HH:mm").format(regDate);
    }
    public String getAnsweredAtText() {
        return answeredAt == null ? "" : new SimpleDateFormat("yyyy.MM.dd HH:mm").format(answeredAt);
    }
}
