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
    info_changed_at DATETIME     NULL,
    suspend_until   DATETIME     NULL,
    suspend_reason  VARCHAR(200) NULL
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
