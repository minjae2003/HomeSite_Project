-- 회원 약관/개인정보 동의 기록 (정책 버전별로 한 줄)
-- 한 줄이 있다 = 그 버전의 [필수] 이용약관, [필수] 개인정보 수집·이용, [필수] 만 14세 이상에 모두 동의함
-- 서버 DB에는 이 파일만 실행하면 됩니다 (기존 데이터는 건드리지 않음)
CREATE TABLE IF NOT EXISTS MEMBER_CONSENT (
    user_id        VARCHAR(50) NOT NULL,
    policy_version VARCHAR(20) NOT NULL,
    agreed_at      DATETIME    DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, policy_version),
    CONSTRAINT fk_consent_member FOREIGN KEY (user_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);
