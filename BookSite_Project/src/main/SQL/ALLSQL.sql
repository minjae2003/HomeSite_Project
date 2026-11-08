-- 전체 설치용: 00~07 파일을 순서대로 합친 것입니다. (기존 데이터가 모두 삭제됩니다)
-- 개별 파일을 수정했다면 이 파일도 같이 맞춰 주세요.

-- ===== 00_reset.sql =====
-- [주의] 모든 테이블과 데이터를 삭제합니다. DB를 처음부터 다시 만들 때만 실행하세요.
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS INQUIRY;
DROP TABLE IF EXISTS MEMBER_CONSENT;
DROP TABLE IF EXISTS BOARD_VIEW_LOG;
DROP TABLE IF EXISTS NOTIFICATION_SETTING;
DROP TABLE IF EXISTS NOTIFICATION;
DROP TABLE IF EXISTS USER_CHECKLIST;
DROP TABLE IF EXISTS CHECKLIST;
DROP TABLE IF EXISTS VISIT_LOG;
DROP TABLE IF EXISTS BOARD_FILE;
DROP TABLE IF EXISTS BOARD_LIKE;
DROP TABLE IF EXISTS BOARD_COMMENT;
DROP TABLE IF EXISTS BOARD_REPLY;
DROP TABLE IF EXISTS BOARD;
DROP TABLE IF EXISTS MEMBER_PROFILE;
DROP TABLE IF EXISTS MEMBER;

SET FOREIGN_KEY_CHECKS = 1;

-- ===== 01_member.sql =====
-- 회원 / 회원 프로필
CREATE TABLE IF NOT EXISTS MEMBER (
    id          VARCHAR(50)  PRIMARY KEY,
    password    VARCHAR(100) NOT NULL,
    name        VARCHAR(50)  NOT NULL,
    nickname    VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL,
    phone       VARCHAR(20)  NULL,
    auth_status VARCHAR(20)  DEFAULT 'Y',
    role        VARCHAR(20)  DEFAULT 'USER',
    reg_date        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    pw_changed_at   DATETIME     NULL,
    info_changed_at DATETIME     NULL
);

CREATE TABLE IF NOT EXISTS MEMBER_PROFILE (
    user_id      VARCHAR(50)  PRIMARY KEY,
    profile_img  VARCHAR(255) NULL,
    bio          VARCHAR(40)  NULL,
    region       VARCHAR(50)  NULL,
    living_years VARCHAR(20)  NULL,
    tags         VARCHAR(200) NULL,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profile_member FOREIGN KEY (user_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);

-- ===== 02_board.sql =====
-- 게시글 / 댓글 / 추천 / 첨부파일
CREATE TABLE IF NOT EXISTS BOARD (
    num             INT AUTO_INCREMENT PRIMARY KEY,
    writer          VARCHAR(50),
    writer_id       VARCHAR(50)  DEFAULT NULL,
    writer_nickname VARCHAR(50)  DEFAULT NULL,
    board_type      VARCHAR(20)  DEFAULT 'FREE',
    category        VARCHAR(50)  DEFAULT 'FREE',
    subject         VARCHAR(200) NOT NULL,
    content         TEXT         NOT NULL,
    readcount       INT          DEFAULT 0,
    like_count      INT          DEFAULT 0,
    reg_date        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_board_writer FOREIGN KEY (writer_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS BOARD_COMMENT (
    comment_num     INT AUTO_INCREMENT PRIMARY KEY,
    board_num       INT NOT NULL,
    writer          VARCHAR(50),
    writer_id       VARCHAR(50),
    writer_nickname VARCHAR(50),
    content         TEXT NOT NULL,
    reg_date        DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comment_board  FOREIGN KEY (board_num) REFERENCES BOARD(num)  ON DELETE CASCADE,
    CONSTRAINT fk_comment_writer FOREIGN KEY (writer_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS BOARD_LIKE (
    board_num INT         NOT NULL,
    user_id   VARCHAR(50) NOT NULL,
    reg_date  DATETIME    DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (board_num, user_id),
    CONSTRAINT fk_like_board FOREIGN KEY (board_num) REFERENCES BOARD(num)  ON DELETE CASCADE,
    CONSTRAINT fk_like_user  FOREIGN KEY (user_id)   REFERENCES MEMBER(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS BOARD_FILE (
    file_num      INT AUTO_INCREMENT PRIMARY KEY,
    board_num     INT          NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    saved_name    VARCHAR(255) NOT NULL,
    file_type     VARCHAR(20)  NOT NULL,
    file_size     BIGINT       DEFAULT 0,
    upload_order  INT          DEFAULT 0,          -- 본문 내 [img1]/[video1] 매칭 순서
    reg_date      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_boardfile_board FOREIGN KEY (board_num) REFERENCES BOARD(num) ON DELETE CASCADE
);

-- ===== 03_board_view_log.sql =====
-- 실시간 인기글 집계용 조회 기록 (같은 사람은 24시간에 1번만 기록, 7일 지난 기록은 자동 정리)
CREATE TABLE IF NOT EXISTS BOARD_VIEW_LOG (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    board_num  INT          NOT NULL,
    viewer_key VARCHAR(120) NOT NULL,
    viewed_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_viewlog_time (viewed_at, board_num),
    INDEX idx_viewlog_viewer (board_num, viewer_key, viewed_at),
    CONSTRAINT fk_viewlog_board FOREIGN KEY (board_num) REFERENCES BOARD(num) ON DELETE CASCADE
);

-- ===== 04_notification.sql =====
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

-- ===== 05_checklist.sql =====
-- 체크리스트 (개인 할 일 / 자취 시작 체크리스트 진행 상황)
CREATE TABLE IF NOT EXISTS CHECKLIST (
    check_id     INT AUTO_INCREMENT PRIMARY KEY,
    member_id    VARCHAR(50)  NOT NULL,
    content      VARCHAR(300) NOT NULL,
    is_completed CHAR(1)      DEFAULT 'N',
    reg_date     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_checklist_member FOREIGN KEY (member_id) REFERENCES MEMBER(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS USER_CHECKLIST (
    USER_ID      VARCHAR(50) PRIMARY KEY,
    CHECKED_KEYS VARCHAR(1000),
    CHECKED_CNT  INT      DEFAULT 0,
    TOTAL_CNT    INT      DEFAULT 0,
    UPDATED_AT   DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_userchecklist_member FOREIGN KEY (USER_ID) REFERENCES MEMBER(id) ON DELETE CASCADE
);

-- ===== 06_visit_log.sql =====
-- 방문자 기록 (하루에 세션당 1건, '오늘 방문자' 집계용)
CREATE TABLE IF NOT EXISTS VISIT_LOG (
    visit_date       DATE         NOT NULL,
    session_id       VARCHAR(100) NOT NULL,
    first_visit_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (visit_date, session_id)
);

-- ===== 07_admin_account.sql =====
-- 관리자 계정 (이미 있으면 건너뜀). 배포 후 반드시 비밀번호를 바꾸세요.
INSERT IGNORE INTO MEMBER (id, password, name, nickname, email, auth_status, role)
VALUES ('admin', 'admin1234', '관리자', '관리자', 'admin@example.com', 'Y', 'ADMIN');

-- ===== 09_member_consent.sql =====
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

-- ===== 10_inquiry.sql =====
-- 1:1 문의 (회원 → 관리자). 관리자가 답변하면 회원에게 알림이 감
-- category: USE(이용 문의) / BUG(오류 신고) / REPORT(게시물·회원 신고) / ACCOUNT(계정·개인정보) / ETC(기타)
-- status  : WAIT(답변 대기) / DONE(답변 완료)
-- 서버 DB에는 이 파일만 실행하면 됩니다 (기존 데이터는 건드리지 않음)
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
