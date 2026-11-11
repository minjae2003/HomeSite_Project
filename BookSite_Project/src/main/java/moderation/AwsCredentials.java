package moderation;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * EC2 인스턴스 역할의 임시 자격증명 (인스턴스 메타데이터 IMDSv2).
 * 만료 5분 전에 새로 받고, EC2가 아니면(응답 없음) 10분 동안 다시 시도하지 않는다.
 */
final class AwsCredentials {
    private AwsCredentials() {}

    static final class Creds {
        final String accessKey, secretKey, token;
        final long expiresAt;
        Creds(String a, String s, String t, long e) { accessKey = a; secretKey = s; token = t; expiresAt = e; }
    }

    private static final String BASE = "http://169.254.169.254/latest";
    private static volatile Creds cached;
    private static volatile long unavailableUntil = 0;

    static synchronized void invalidate() { cached = null; }

    static synchronized Creds get() {
        long now = System.currentTimeMillis();
        if (cached != null && cached.expiresAt - now > 5 * 60 * 1000L) return cached;
        if (now < unavailableUntil) return null;
        try {
            String imdsToken = request("PUT", BASE + "/api/token", null, "X-aws-ec2-metadata-token-ttl-seconds", "300");
            String role = request("GET", BASE + "/meta-data/iam/security-credentials/", imdsToken, null, null);
            if (role == null || role.trim().isEmpty()) throw new IllegalStateException("no role");
            role = role.trim().split("\\s+")[0];
            String json = request("GET", BASE + "/meta-data/iam/security-credentials/" + role, imdsToken, null, null);
            String ak = field(json, "AccessKeyId"), sk = field(json, "SecretAccessKey"), tk = field(json, "Token"), exp = field(json, "Expiration");
            if (ak == null || sk == null || tk == null) throw new IllegalStateException("bad credentials");
            long expiresAt = exp == null ? now + 30 * 60 * 1000L : Instant.parse(exp).toEpochMilli();
            cached = new Creds(ak, sk, tk, expiresAt);
            return cached;
        } catch (Exception e) {
            unavailableUntil = now + 10 * 60 * 1000L;
            cached = null;
            return null;
        }
    }

    private static String request(String method, String url, String imdsToken, String hName, String hValue) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        conn.setRequestMethod(method);
        conn.setConnectTimeout(800);
        conn.setReadTimeout(1500);
        if (imdsToken != null) conn.setRequestProperty("X-aws-ec2-metadata-token", imdsToken);
        if (hName != null) conn.setRequestProperty(hName, hValue);
        try {
            if (conn.getResponseCode() != 200) throw new IllegalStateException("IMDS " + conn.getResponseCode());
            try (InputStream in = conn.getInputStream()) {
                return new String(ImageModeration.readAll(in), StandardCharsets.UTF_8);
            }
        } finally {
            conn.disconnect();
        }
    }

    static String field(String json, String key) {
        Matcher m = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"").matcher(json == null ? "" : json);
        return m.find() ? m.group(1) : null;
    }
}
