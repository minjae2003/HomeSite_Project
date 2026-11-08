package util;

/**
 * 사이트 운영 정보와 정책 버전.
 * ※ 약관·개인정보처리방침을 바꿔 다시 동의를 받아야 하면 POLICY_VERSION과 EFFECTIVE_DATE를 새 날짜로 바꿀 것
 *   (다음 로그인 때 모든 회원에게 동의 화면이 다시 뜸)
 */
public final class SiteInfo {
    private SiteInfo() {}

    public static final String SITE_NAME = "자취의 품격";
    public static final String SITE_URL = "https://jachiclass.com";

    public static final String OPERATOR = "자취의 품격 운영자";
    public static final String CONTACT_EMAIL = "alswo00258@gmail.com";

    public static final String POLICY_VERSION = "2026-11-09";
    public static final String EFFECTIVE_DATE = "2026년 11월 9일";
}
