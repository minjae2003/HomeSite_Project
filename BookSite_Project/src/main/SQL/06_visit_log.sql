-- 방문자 기록 (하루에 세션당 1건, '오늘 방문자' 집계용)
CREATE TABLE IF NOT EXISTS VISIT_LOG (
    visit_date       DATE         NOT NULL,
    session_id       VARCHAR(100) NOT NULL,
    first_visit_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (visit_date, session_id)
);
