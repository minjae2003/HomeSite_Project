package util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/** 비밀번호 해시 (PBKDF2-HMAC-SHA256). 저장 형식: pbkdf2$반복횟수$솔트$해시 */
public final class PasswordUtil {
    private PasswordUtil() {}

    private static final String PREFIX = "pbkdf2";
    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 310_000;
    private static final int SALT_BYTES = 16;
    private static final int HASH_BITS = 256;
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String hash(String raw) {
        if (raw == null) throw new IllegalArgumentException("password is null");
        byte[] salt = new byte[SALT_BYTES];
        RANDOM.nextBytes(salt);
        byte[] dk = pbkdf2(raw.toCharArray(), salt, ITERATIONS, HASH_BITS);
        Base64.Encoder b64 = Base64.getEncoder();
        return PREFIX + "$" + ITERATIONS + "$" + b64.encodeToString(salt) + "$" + b64.encodeToString(dk);
    }

    public static boolean verify(String raw, String stored) {
        if (raw == null || !isHashed(stored)) return false;
        try {
            String[] parts = stored.split("\\$");
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            byte[] actual = pbkdf2(raw.toCharArray(), salt, iterations, expected.length * 8);
            return MessageDigest.isEqual(expected, actual);   // 시간 차이로 정답을 추측하지 못하도록 고정 시간 비교
        } catch (RuntimeException e) {
            return false;
        }
    }

    /** 없는 아이디로 로그인할 때도 해시 계산 시간을 똑같이 쓰기 위한 가짜 검증 (응답 시간으로 아이디 존재 여부를 알아내는 것 방지) */
    private static volatile String dummyHash;
    public static void dummyVerify(String raw) {
        if (dummyHash == null) dummyHash = hash("dummy-password-for-timing");
        verify(raw == null ? "" : raw, dummyHash);
    }

    public static String checkPolicy(String raw, String id) {
        if (raw == null || raw.length() < 8) return "비밀번호는 8자 이상이어야 합니다.";
        if (raw.length() > 100) return "비밀번호는 100자 이하로 입력해 주세요.";
        if (!raw.matches(".*[A-Za-z].*") || !raw.matches(".*[0-9].*")) return "비밀번호는 영문과 숫자를 모두 포함해야 합니다.";
        if (id != null && raw.equalsIgnoreCase(id.trim())) return "아이디와 같은 비밀번호는 사용할 수 없습니다.";
        return null;
    }

    public static boolean isHashed(String stored) {
        return stored != null && stored.startsWith(PREFIX + "$") && stored.split("\\$").length == 4;
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int bits) {
        try {
            KeySpec spec = new PBEKeySpec(password, salt, iterations, bits);
            return SecretKeyFactory.getInstance(ALGORITHM).generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("PBKDF2 unavailable", e);
        }
    }
}
