package util;

import javax.servlet.http.HttpServletRequest;

/**
 * 실제 접속자 IP.
 * Nginx 뒤에서는 모든 요청의 getRemoteAddr()가 127.0.0.1이라, IP별 시도 제한이 전체 사용자를 한 사람으로 취급하게 됨.
 * ※ 요청이 같은 서버(127.0.0.1)의 Nginx를 거쳐 왔을 때만 X-Real-IP를 믿는다 (외부에서 헤더를 위조해도 무시됨)
 */
public final class ClientIp {
    private ClientIp() {}

    public static String get(HttpServletRequest request) {
        String remote = request.getRemoteAddr();
        if ("127.0.0.1".equals(remote) || "0:0:0:0:0:0:0:1".equals(remote) || "::1".equals(remote)) {
            String real = request.getHeader("X-Real-IP");
            if (real != null && real.matches("[0-9a-fA-F:.]{3,45}")) return real;
        }
        return remote;
    }
}
