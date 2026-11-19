package util;

/**
 * 사이트 운영 정보와 정책 버전.
 * ※ 약관·개인정보처리방침을 바꿔 다시 동의를 받아야 하면 POLICY_VERSION과 EFFECTIVE_DATE를 새 날짜로 바꿀 것
 *   (다음 로그인 때 모든 회원에게 동의 화면이 다시 뜸)
 * ※ 값은 static 블록에서 넣는다. "= 문자열"로 바로 넣으면 컴파일러가 JSP 안에 값을 복사해 넣어서,
 *   여기만 바꾸면 수정하지 않은 JSP(footer.jsp 등)에는 예전 값이 계속 보인다.
 */
public final class SiteInfo {
    private SiteInfo() {}

    public static final String SITE_NAME;
    public static final String SITE_URL;

    public static final String OPERATOR;
    public static final String CONTACT_EMAIL;      // 대표 문의 이메일
    public static final String CONTACT_EMAIL_SUB;  // 보조 이메일

    public static final String MAIL_FROM;          // 안내 메일 보내는 주소 (AWS SES에서 도메인 인증 필요)
    public static final String MAIL_FROM_NAME;

    public static final String POLICY_VERSION;
    public static final String EFFECTIVE_DATE;

    static {
        SITE_NAME = "자취의 품격";
        SITE_URL = "https://jachiclass.com";

        OPERATOR = "자취의 품격 운영자";
        CONTACT_EMAIL = "sienna1982@naver.com";
        CONTACT_EMAIL_SUB = "alswo00258@gmail.com";

        MAIL_FROM = "no-reply@jachiclass.com";
        MAIL_FROM_NAME = "자취의 품격";

        POLICY_VERSION = "2026-11-09";
        EFFECTIVE_DATE = "2026년 11월 9일";
    }
}
