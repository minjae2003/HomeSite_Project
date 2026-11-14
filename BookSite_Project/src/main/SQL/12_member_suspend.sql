-- [기존 DB 1회 실행용] 회원 이용 정지 기능 컬럼 추가
ALTER TABLE MEMBER
    ADD COLUMN suspend_until  DATETIME     NULL,
    ADD COLUMN suspend_reason VARCHAR(200) NULL;
