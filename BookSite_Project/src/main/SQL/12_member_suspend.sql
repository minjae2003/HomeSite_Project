-- [기존 DB 1회 실행용] 회원 이용 정지 기능 컬럼 추가
-- 01_member.sql / ALLSQL.sql 로 새로 만든 DB에는 이미 들어 있으므로 실행하지 마세요 (Duplicate column 에러)
ALTER TABLE MEMBER
    ADD COLUMN suspend_until  DATETIME     NULL,
    ADD COLUMN suspend_reason VARCHAR(200) NULL;
