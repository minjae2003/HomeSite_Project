-- 1:1 문의 (회원 → 관리자). 관리자가 답변하면 회원에게 알림이 감
-- category: USE(이용 문의) / BUG(오류 신고) / REPORT(게시물·회원 신고) / ACCOUNT(계정·개인정보) / ETC(기타)
-- status  : WAIT(답변 대기) / DONE(답변 완료)
CREATE TABLE IF NOT EXISTS INQUIRY (
    inquiry_num  INT AUTO_INCREMENT PRIMARY KEY,
    user_id      VARCHAR(50)  NOT NULL,
    category     VARCHAR(20)  NOT NULL,
    subject      VARCHAR(100) NOT NULL,
    content      TEXT         NOT NULL,
    page_url     VARCHAR(300) NULL,
    status       VARCHAR(10)  DEFAULT 'WAIT',
    answer       TEXT         NULL,
    answered_by  VARCHAR(50)  NULL,
    answered_at  DATETIME     NULL,
    reg_date     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inquiry_user (user_id, inquiry_num),
    INDEX idx_inquiry_status (status, inquiry_num),
    CONSTRAINT fk_inquiry_member FOREIGN KEY (user_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);
