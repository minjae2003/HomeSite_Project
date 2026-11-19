package mail;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import java.util.TimeZone;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import moderation.AwsCredentials;

/**
 * Amazon SES(v2 API)로 메일 발송. 자격증명은 EC2 인스턴스 역할(키 저장 없음).
 * EC2가 아니면(로컬 개발) 실제로 보내지 않고 서버 콘솔에 내용을 출력한다.
 */
public final class SesMailer {
    private SesMailer() {}

    static final String REGION = "ap-northeast-2";
    static final String HOST = "email." + REGION + ".amazonaws.com";
    static final String PATH = "/v2/email/outbound-emails";

    /** 하루 전체 발송 상한 (공격으로 대량 발송돼도 비용·평판 보호) */
    private static final int DAILY_LIMIT = 300;
    private static long dayStart = 0;
    private static int sentToday = 0;

    public static boolean send(String to, String subject, String text, String html) {
        if (to == null || !to.matches("[^\\s@<>\",;]+@[^\\s@<>\",;]+\\.[^\\s@<>\",;]+") || to.length() > 254) return false;
        if (!takeDaily()) {
            System.err.println("[SesMailer] 하루 발송 상한 초과로 발송 안 함");
            return false;
        }
        AwsCredentials.Creds c = AwsCredentials.get();
        if (c == null) {
            System.out.println("[SesMailer:로컬] EC2가 아니라 실제 발송 안 함\nTo: " + to + "\nSubject: " + subject + "\n" + text);
            return true;
        }
        try {
            String body = json(to, subject, text, html);
            Date now = new Date();
            String amzDate = fmt("yyyyMMdd'T'HHmmss'Z'", now);
            String date = fmt("yyyyMMdd", now);
            String contentType = "application/json";
            String auth = authorization(c.accessKey, c.secretKey, c.token, amzDate, date, contentType, body);

            HttpURLConnection conn = (HttpURLConnection) new URL("https://" + HOST + PATH).openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(5000);
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", contentType);
            conn.setRequestProperty("X-Amz-Date", amzDate);
            conn.setRequestProperty("X-Amz-Security-Token", c.token);
            conn.setRequestProperty("Authorization", auth);
            try (OutputStream out = conn.getOutputStream()) {
                out.write(body.getBytes(StandardCharsets.UTF_8));
            }
            int code = conn.getResponseCode();
            if (code == 200) return true;
            String err = "";
            try (InputStream in = conn.getErrorStream()) {
                if (in != null) err = new String(readAll(in), StandardCharsets.UTF_8);
            }
            if (code == 403) AwsCredentials.invalidate();
            System.err.println("[SesMailer] 발송 실패 " + code + " " + (err.length() > 300 ? err.substring(0, 300) : err));
            return false;
        } catch (Exception e) {
            System.err.println("[SesMailer] 발송 오류 " + e);
            return false;
        }
    }

    private static synchronized boolean takeDaily() {
        long now = System.currentTimeMillis();
        if (now - dayStart > 24 * 60 * 60 * 1000L) { dayStart = now; sentToday = 0; }
        if (sentToday >= DAILY_LIMIT) return false;
        sentToday++;
        return true;
    }

    static String json(String to, String subject, String text, String html) {
        String from = util.SiteInfo.MAIL_FROM_NAME == null ? util.SiteInfo.MAIL_FROM
                : "=?UTF-8?B?" + Base64.getEncoder().encodeToString(util.SiteInfo.MAIL_FROM_NAME.getBytes(StandardCharsets.UTF_8))
                  + "?= <" + util.SiteInfo.MAIL_FROM + ">";
        StringBuilder sb = new StringBuilder();
        sb.append("{\"FromEmailAddress\":").append(q(from))
          .append(",\"Destination\":{\"ToAddresses\":[").append(q(to)).append("]}")
          .append(",\"Content\":{\"Simple\":{\"Subject\":{\"Data\":").append(q(subject)).append(",\"Charset\":\"UTF-8\"}")
          .append(",\"Body\":{\"Text\":{\"Data\":").append(q(text)).append(",\"Charset\":\"UTF-8\"}");
        if (html != null) sb.append(",\"Html\":{\"Data\":").append(q(html)).append(",\"Charset\":\"UTF-8\"}");
        sb.append("}}}}");
        return sb.toString();
    }

    static String q(String s) {
        StringBuilder sb = new StringBuilder("\"");
        for (char ch : s.toCharArray()) {
            switch (ch) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (ch < 0x20 || ch == '<' || ch == '>' || ch == '&' || ch == 0x2028 || ch == 0x2029) sb.append(String.format("\\u%04x", (int) ch));
                    else sb.append(ch);
            }
        }
        return sb.append('"').toString();
    }

    static String authorization(String accessKey, String secretKey, String token, String amzDate, String date,
                                String contentType, String body) throws Exception {
        String signedHeaders = "content-type;host;x-amz-date;x-amz-security-token";
        String canonical = "POST\n" + PATH + "\n\n"
                + "content-type:" + contentType + "\n"
                + "host:" + HOST + "\n"
                + "x-amz-date:" + amzDate + "\n"
                + "x-amz-security-token:" + token + "\n"
                + "\n" + signedHeaders + "\n" + hex(sha256(body.getBytes(StandardCharsets.UTF_8)));
        String scope = date + "/" + REGION + "/ses/aws4_request";
        String toSign = "AWS4-HMAC-SHA256\n" + amzDate + "\n" + scope + "\n" + hex(sha256(canonical.getBytes(StandardCharsets.UTF_8)));
        byte[] k = hmac(("AWS4" + secretKey).getBytes(StandardCharsets.UTF_8), date);
        k = hmac(k, REGION);
        k = hmac(k, "ses");
        k = hmac(k, "aws4_request");
        String signature = hex(hmac(k, toSign));
        return "AWS4-HMAC-SHA256 Credential=" + accessKey + "/" + scope + ", SignedHeaders=" + signedHeaders + ", Signature=" + signature;
    }

    private static byte[] hmac(byte[] key, String data) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key, "HmacSHA256"));
        return mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
    }
    private static byte[] sha256(byte[] data) throws Exception { return MessageDigest.getInstance("SHA-256").digest(data); }
    private static String hex(byte[] b) {
        StringBuilder sb = new StringBuilder();
        for (byte x : b) sb.append(String.format("%02x", x));
        return sb.toString();
    }
    private static String fmt(String pattern, Date d) {
        SimpleDateFormat f = new SimpleDateFormat(pattern);
        f.setTimeZone(TimeZone.getTimeZone("UTC"));
        return f.format(d);
    }
    private static byte[] readAll(InputStream in) throws java.io.IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = in.read(buf)) != -1 && out.size() < 64 * 1024) out.write(buf, 0, n);
        return out.toByteArray();
    }
}
