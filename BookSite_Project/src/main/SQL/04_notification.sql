-- 알림 / 알림 수신 설정
-- type: COMMENT(내 글에 댓글) / LIKE(내 글 추천) / NOTICE(새 공지사항)
CREATE TABLE IF NOT EXISTS NOTIFICATION (
    noti_num        INT AUTO_INCREMENT PRIMARY KEY,
    receiver_id     VARCHAR(50)  NOT NULL,
    type            VARCHAR(20)  NOT NULL,
    actor_id        VARCHAR(50),
    actor_nickname  VARCHAR(50),
    board_num       INT,
    board_subject   VARCHAR(200),
    preview         VARCHAR(200) NULL,
    is_read         CHAR(1)      DEFAULT 'N',
    reg_date        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_noti_receiver (receiver_id, is_read),
    CONSTRAINT fk_noti_receiver FOREIGN KEY (receiver_id) REFERENCES MEMBER(id) ON DELETE CASCADE,
    CONSTRAINT fk_noti_board    FOREIGN KEY (board_num)   REFERENCES BOARD(num)  ON DELETE CASCADE
);

-- 행이 없으면 모두 켜짐으로 처리
CREATE TABLE IF NOT EXISTS NOTIFICATION_SETTING (
    user_id    VARCHAR(50) PRIMARY KEY,
    comment_on CHAR(1) DEFAULT 'Y',
    like_on    CHAR(1) DEFAULT 'Y',
    notice_on  CHAR(1) DEFAULT 'Y',
    CONSTRAINT fk_notisetting_member FOREIGN KEY (user_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);
