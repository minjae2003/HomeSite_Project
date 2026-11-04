-- 실시간 인기글 집계용 조회 기록 (같은 사람은 24시간에 1번만 기록, 7일 지난 기록은 자동 정리)
CREATE TABLE IF NOT EXISTS BOARD_VIEW_LOG (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    board_num  INT NOT NULL,
    viewer_key VARCHAR(120) NOT NULL,
    viewed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_viewlog_time (viewed_at, board_num),
    INDEX idx_viewlog_viewer (board_num, viewer_key, viewed_at),
    CONSTRAINT fk_viewlog_board FOREIGN KEY (board_num) REFERENCES BOARD(num) ON DELETE CASCADE
);
