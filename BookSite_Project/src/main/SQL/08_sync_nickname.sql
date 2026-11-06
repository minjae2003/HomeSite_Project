-- [한 번만 실행] 닉네임을 바꾸기 전에 쓴 글·댓글·알림의 작성자 이름을 현재 닉네임으로 맞춤
-- (이 업데이트 이후로는 닉네임을 바꿀 때 자동으로 같이 바뀌므로 다시 실행할 필요 없음)
UPDATE BOARD b JOIN MEMBER m ON b.writer_id = m.id
   SET b.writer = m.nickname, b.writer_nickname = m.nickname;

UPDATE BOARD_COMMENT c JOIN MEMBER m ON c.writer_id = m.id
   SET c.writer = m.nickname, c.writer_nickname = m.nickname;

UPDATE NOTIFICATION n JOIN MEMBER m ON n.actor_id = m.id
   SET n.actor_nickname = m.nickname;
