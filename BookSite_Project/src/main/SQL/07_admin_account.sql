-- 관리자 계정 생성
INSERT IGNORE INTO MEMBER (id, password, name, nickname, email, auth_status, role)
VALUES ('admin', 'admin1234', '관리자', '관리자', 'admin@example.com', 'Y', 'ADMIN');

INSERT IGNORE INTO MEMBER (id, password, name, nickname, email, auth_status, role)
VALUES ('admin2', 'adminqpalzm', '관리자2', '관리자2', 'admin@example.com', 'Y', 'ADMIN');