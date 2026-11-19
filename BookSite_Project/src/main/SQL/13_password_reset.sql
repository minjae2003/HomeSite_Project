-- 비밀번호 재설정 메일 링크 (토큰 원본은 저장하지 않고 SHA-256 값만 저장)
-- 만료 시각은 서버 시간대와 상관없게 Java 밀리초(epoch)로 저장
-- 서버 DB에는 이 파일만 실행하면 됩니다 (기존 데이터는 건드리지 않음)
CREATE TABLE IF NOT EXISTS PASSWORD_RESET (
    token_hash  CHAR(64)    NOT NULL PRIMARY KEY,
    member_id   VARCHAR(50) NOT NULL,
    expires_at  BIGINT      NOT NULL,
    created_at  BIGINT      NOT NULL,
    KEY idx_password_reset_member (member_id)
);
