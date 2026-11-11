-- 금칙어(BAN) / 예외 단어(ALLOW)
-- 기본 목록은 관리자 화면(/admin/bannedWords.jsp)의 [기본 목록 넣기] 버튼으로 추가
-- 서버 DB에는 이 파일만 실행하면 됩니다 (기존 데이터는 건드리지 않음)
CREATE TABLE IF NOT EXISTS BANNED_WORD (
    word_id   INT AUTO_INCREMENT PRIMARY KEY,
    word      VARCHAR(50) NOT NULL,
    type      VARCHAR(10) NOT NULL DEFAULT 'BAN',
    reg_date  DATETIME    DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_banned_word (word, type)
);
