-- 알림 테이블 (NOTIFICATION) - 헤더 알림 / 마이페이지 전체 알림
-- type: COMMENT(내 글에 댓글) / LIKE(내 글 추천) / NOTICE(새 공지사항)
CREATE TABLE NOTIFICATION (
    noti_num        INT AUTO_INCREMENT PRIMARY KEY,
    receiver_id     VARCHAR(50)  NOT NULL,              -- 알림 받는 회원
    type            VARCHAR(20)  NOT NULL,
    actor_id        VARCHAR(50),                         -- 알림을 발생시킨 회원
    actor_nickname  VARCHAR(50),
    board_num       INT,                                 -- 관련 게시글
    board_subject   VARCHAR(200),
    is_read         CHAR(1)      DEFAULT 'N',
    reg_date        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_noti_receiver (receiver_id, is_read),
    CONSTRAINT fk_noti_receiver FOREIGN KEY (receiver_id) REFERENCES MEMBER(id) ON DELETE CASCADE,
    CONSTRAINT fk_noti_board    FOREIGN KEY (board_num)   REFERENCES BOARD(num)  ON DELETE CASCADE
);
ALTER TABLE NOTIFICATION ADD COLUMN preview VARCHAR(200) NULL AFTER board_subject;

-- 2) 알림 수신 설정 (행이 없으면 모두 켜짐으로 처리)
CREATE TABLE NOTIFICATION_SETTING (
    user_id    VARCHAR(50) PRIMARY KEY,
    comment_on CHAR(1) DEFAULT 'Y',   -- 댓글 알림
    like_on    CHAR(1) DEFAULT 'Y',   -- 추천 알림
    notice_on  CHAR(1) DEFAULT 'Y',   -- 공지사항 알림
    CONSTRAINT fk_notisetting_member FOREIGN KEY (user_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);


    

    CREATE TABLE MEMBER_PROFILE (
    user_id      VARCHAR(50)  PRIMARY KEY,
    profile_img  VARCHAR(255) NULL,   -- uploads/profile/ 안의 저장 파일명
    bio          VARCHAR(40)  NULL,   -- 한줄 소개
    region       VARCHAR(50)  NULL,   -- 거주 지역 (예: 경상남도 양산시)
    living_years VARCHAR(20)  NULL,   -- 자취 연차
    tags         VARCHAR(200) NULL,   -- 관심 태그 (콤마 구분)
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profile_member FOREIGN KEY (user_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);