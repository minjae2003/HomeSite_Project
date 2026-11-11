package moderation;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Base64;
import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.imageio.ImageIO;

/**
 * AWS Rekognition(DetectModerationLabels)으로 업로드 사진의 유해성 검사.
 *  - 권한은 EC2 인스턴스 역할에서 자동으로 받음 (접근 키를 코드·파일에 두지 않음)
 *  - EC2가 아닌 곳(내 PC)에서는 역할이 없으므로 검사를 건너뜀
 *  - AWS 오류·시간 초과 시에는 업로드를 막지 않고 서버 로그에만 남김
 *  - 외부 라이브러리 없이 표준 Java로 AWS 요청 서명(SigV4)
 */
public final class ImageModeration {
    private ImageModeration() {}

    public enum Status { OK, BLOCKED, UNSUPPORTED, LIMITED, SKIPPED }

    public static final class Result {
        public final Status status;
        public final String label;
        Result(Status status, String label) { this.status = status; this.label = label; }
        public boolean rejected() { return status == Status.BLOCKED || status == Status.UNSUPPORTED || status == Status.LIMITED; }
        /** 사용자에게 보여줄 안내 */
        public String message() {
            switch (status) {
                case BLOCKED: return "부적절한 사진으로 판단되어 올릴 수 없어요. (선정적·폭력적·혐오 이미지)";
                case UNSUPPORTED: return "이 형식의 사진은 검사할 수 없어요. JPG 또는 PNG로 바꿔서 올려 주세요.";
                case LIMITED: return "사진을 너무 많이 올렸어요. 잠시 후 다시 시도해 주세요.";
                default: return "";
            }
        }
    }

    static final String REGION = "ap-northeast-2";
    private static final String HOST = "rekognition." + REGION + ".amazonaws.com";
    private static final float MIN_CONFIDENCE = 80f;
    private static final int MAX_BYTES = 5 * 1024 * 1024;
    private static final int MAX_SIDE = 1600;

    /** 이 분류(또는 그 하위)가 나오면 차단. 수영복·속옷·술·담배·도박, 단순 무기 등은 허용 */
    static final Set<String> BLOCK = new HashSet<String>(Arrays.asList(
        // 분류 체계 v7
        "Explicit", "Explicit Nudity", "Explicit Sexual Activity", "Sex Toys",
        "Graphic Violence", "Visually Disturbing", "Death and Emaciation", "Crashes",
        "Hate Symbols", "Nazi Party", "White Supremacy", "Extremist",
        // 예전 분류 체계 v6
        "Graphic Male Nudity", "Graphic Female Nudity", "Sexual Activity", "Illustrated Explicit Nudity", "Adult Toys",
        "Graphic Violence Or Gore", "Physical Violence", "Weapon Violence", "Self Injury",
        "Emaciated Bodies", "Corpses", "Hanging", "Air Crash", "Explosions And Blasts"));

    // 사용자별 검사 횟수 제한 (10분에 30장)
    private static final int LIMIT_COUNT = 30;
    private static final long LIMIT_WINDOW = 10 * 60 * 1000L;
    private static final Map<String, long[]> usage = new ConcurrentHashMap<String, long[]>();

    /**
     * 사진 검사.
     * @param bytes 원본 파일 내용
     * @param ext   확장자 (jpg, png, gif, bmp, webp …)
     * @param userKey 횟수 제한용 사용자 키 (아이디)
     */
    public static Result check(byte[] bytes, String ext, String userKey) {
        AwsCredentials.Creds creds = AwsCredentials.get();
        if (creds == null) return new Result(Status.SKIPPED, null);          // EC2 역할 없음 (내 PC 등)

        if (!takeQuota(userKey)) return new Result(Status.LIMITED, null);

        byte[] img = prepare(bytes, ext);
        if (img == null) return new Result(Status.UNSUPPORTED, null);

        try {
            String body = "{\"Image\":{\"Bytes\":\"" + Base64.getEncoder().encodeToString(img)
                        + "\"},\"MinConfidence\":" + MIN_CONFIDENCE + "}";
            String res = call(creds, body);
            if (res == null) return new Result(Status.SKIPPED, null);
            String hit = blockedLabel(res);
            return hit == null ? new Result(Status.OK, null) : new Result(Status.BLOCKED, hit);
        } catch (Exception e) {
            System.err.println("[ImageModeration] 검사 실패 (업로드는 허용): " + e);
            return new Result(Status.SKIPPED, null);
        }
    }

    private static boolean takeQuota(String key) {
        if (key == null) key = "-";
        long now = System.currentTimeMillis();
        if (usage.size() > 5000) usage.clear();
        long[] u = usage.computeIfAbsent(key, k -> new long[] { now, 0 });
        synchronized (u) {
            if (now - u[0] > LIMIT_WINDOW) { u[0] = now; u[1] = 0; }
            return ++u[1] <= LIMIT_COUNT;
        }
    }

    /** Rekognition이 받는 형식(JPEG/PNG, 5MB 이하)으로 준비. 읽을 수 없는 형식이면 null */
    static byte[] prepare(byte[] bytes, String ext) {
        String e = ext == null ? "" : ext.toLowerCase();
        boolean native_ = e.equals("jpg") || e.equals("jpeg") || e.equals("png");
        if (native_ && bytes.length <= MAX_BYTES) return bytes;
        try {
            BufferedImage src = ImageIO.read(new ByteArrayInputStream(bytes));   // gif는 첫 장면, webp는 읽지 못함(null)
            if (src == null) return null;
            int w = src.getWidth(), h = src.getHeight();
            double scale = Math.min(1.0, (double) MAX_SIDE / Math.max(w, h));
            int nw = Math.max(1, (int) Math.round(w * scale)), nh = Math.max(1, (int) Math.round(h * scale));
            BufferedImage out = new BufferedImage(nw, nh, BufferedImage.TYPE_INT_RGB);
            Graphics2D g = out.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.setColor(java.awt.Color.WHITE);
            g.fillRect(0, 0, nw, nh);
            g.drawImage(src, 0, 0, nw, nh, null);
            g.dispose();
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ImageIO.write(out, "jpg", bos);
            return bos.size() <= MAX_BYTES ? bos.toByteArray() : null;
        } catch (Exception ex) {
            return null;
        }
    }

    private static final Pattern LABEL_OBJ = Pattern.compile("\\{[^{}]*\"Name\"[^{}]*\\}");
    private static final Pattern NAME = Pattern.compile("\"Name\"\\s*:\\s*\"([^\"]*)\"");
    private static final Pattern PARENT = Pattern.compile("\"ParentName\"\\s*:\\s*\"([^\"]*)\"");
    private static final Pattern CONF = Pattern.compile("\"Confidence\"\\s*:\\s*([0-9.]+)");

    /** 응답에서 차단 대상 분류가 있으면 그 이름, 없으면 null */
    static String blockedLabel(String json) {
        int at = json.indexOf("\"ModerationLabels\"");
        if (at < 0) return null;
        Matcher m = LABEL_OBJ.matcher(json.substring(at));
        while (m.find()) {
            String obj = m.group();
            Matcher c = CONF.matcher(obj);
            if (c.find() && Float.parseFloat(c.group(1)) < MIN_CONFIDENCE) continue;
            Matcher n = NAME.matcher(obj);
            Matcher p = PARENT.matcher(obj);
            String name = n.find() ? n.group(1) : "";
            String parent = p.find() ? p.group(1) : "";
            if (BLOCK.contains(name)) return name;
            if (BLOCK.contains(parent)) return parent + " / " + name;
        }
        return null;
    }

    private static String call(AwsCredentials.Creds c, String body) throws Exception {
        Date now = new Date();
        String amzDate = fmt("yyyyMMdd'T'HHmmss'Z'", now);
        String date = fmt("yyyyMMdd", now);
        String target = "RekognitionService.DetectModerationLabels";
        String contentType = "application/x-amz-json-1.1";

        String auth = authorization(c.accessKey, c.secretKey, c.token, amzDate, date, contentType, target, body);

        HttpURLConnection conn = (HttpURLConnection) new URL("https://" + HOST + "/").openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setConnectTimeout(3000);
        conn.setReadTimeout(8000);
        conn.setRequestProperty("Content-Type", contentType);
        conn.setRequestProperty("X-Amz-Date", amzDate);
        conn.setRequestProperty("X-Amz-Security-Token", c.token);
        conn.setRequestProperty("X-Amz-Target", target);
        conn.setRequestProperty("Authorization", auth);
        byte[] payload = body.getBytes(StandardCharsets.UTF_8);
        try (OutputStream os = conn.getOutputStream()) { os.write(payload); }

        int code = conn.getResponseCode();
        InputStream in = code < 400 ? conn.getInputStream() : conn.getErrorStream();
        String res = in == null ? "" : new String(readAll(in), StandardCharsets.UTF_8);
        conn.disconnect();
        if (code != 200) {
            System.err.println("[ImageModeration] Rekognition 응답 " + code + ": " + (res.length() > 300 ? res.substring(0, 300) : res));
            if (code == 400 || code == 403) AwsCredentials.invalidate();
            return null;
        }
        return res;
    }

    /** AWS Signature Version 4 Authorization 헤더 */
    static String authorization(String accessKey, String secretKey, String token, String amzDate, String date,
                                String contentType, String target, String body) throws Exception {
        String signedHeaders = "content-type;host;x-amz-date;x-amz-security-token;x-amz-target";
        String canonical = "POST\n/\n\n"
                + "content-type:" + contentType + "\n"
                + "host:" + HOST + "\n"
                + "x-amz-date:" + amzDate + "\n"
                + "x-amz-security-token:" + token + "\n"
                + "x-amz-target:" + target + "\n"
                + "\n" + signedHeaders + "\n" + hex(sha256(body.getBytes(StandardCharsets.UTF_8)));
        String scope = date + "/" + REGION + "/rekognition/aws4_request";
        String toSign = "AWS4-HMAC-SHA256\n" + amzDate + "\n" + scope + "\n" + hex(sha256(canonical.getBytes(StandardCharsets.UTF_8)));
        String signature = hex(hmac(signingKey(secretKey, date, REGION, "rekognition"), toSign));
        return "AWS4-HMAC-SHA256 Credential=" + accessKey + "/" + scope + ", SignedHeaders=" + signedHeaders + ", Signature=" + signature;
    }

    static byte[] signingKey(String secret, String date, String region, String service) throws Exception {
        byte[] k = hmac(("AWS4" + secret).getBytes(StandardCharsets.UTF_8), date);
        k = hmac(k, region);
        k = hmac(k, service);
        return hmac(k, "aws4_request");
    }

    static byte[] hmac(byte[] key, String data) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key, "HmacSHA256"));
        return mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
    }

    static byte[] sha256(byte[] data) throws Exception { return MessageDigest.getInstance("SHA-256").digest(data); }

    static String hex(byte[] b) {
        StringBuilder sb = new StringBuilder(b.length * 2);
        for (byte x : b) sb.append(String.format("%02x", x & 0xff));
        return sb.toString();
    }

    private static String fmt(String pattern, Date d) {
        SimpleDateFormat f = new SimpleDateFormat(pattern);
        f.setTimeZone(TimeZone.getTimeZone("UTC"));
        return f.format(d);
    }

    static byte[] readAll(InputStream in) throws java.io.IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
        return out.toByteArray();
    }
}
