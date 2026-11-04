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
