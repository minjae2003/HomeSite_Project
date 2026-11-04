-- 관리자 계정 (이미 있으면 건너뜀). 배포 후 반드시 비밀번호를 바꾸세요.
INSERT IGNORE INTO MEMBER (id, password, name, nickname, email, auth_status, role)
VALUES ('admin', 'admin1234', '관리자', '관리자', 'admin@example.com', 'Y', 'ADMIN');
