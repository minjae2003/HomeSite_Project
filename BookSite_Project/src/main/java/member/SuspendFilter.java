package member;

import java.io.IOException;
import java.sql.Timestamp;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 이용 정지된 회원이 이미 로그인해 있던 경우, 글·댓글·추천 등 POST 요청을 막고 로그아웃시킨다.
 * (새 로그인은 loginPro.jsp에서 막음) 확인 결과는 세션에 30초간 기억해 DB 조회를 줄인다.
 */
@WebFilter("/*")
public class SuspendFilter implements Filter {
    private static final String CHECKED_AT = "SUSPEND_CHECKED_AT";
    private static final long RECHECK_MS = 30_000;

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            HttpSession session = request.getSession(false);
            String id = session == null ? null : (String) session.getAttribute("id");
            if (id != null && !"ADMIN".equals(session.getAttribute("role"))) {
                Long at = (Long) session.getAttribute(CHECKED_AT);
                long now = System.currentTimeMillis();
                if (at == null || now - at > RECHECK_MS) {
                    Timestamp until = MemberDAO.getInstance().getActiveSuspension(id);
                    if (until != null) {
                        session.invalidate();
                        reject(request, response);
                        return;
                    }
                    session.setAttribute(CHECKED_AT, now);
                }
            }
        }
        chain.doFilter(req, res);
    }

    private void reject(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        String msg = "이용이 정지된 계정입니다. 자세한 내용은 다시 로그인하면 확인할 수 있어요.";
        if (request.getHeader("X-CSRF-Token") != null) {
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"ok\":false,\"message\":\"" + msg + "\"}");
            return;
        }
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<script>alert('" + msg + "'); location.href='"
                + request.getContextPath() + "/member/loginForm.jsp';</script>");
    }

    @Override public void init(FilterConfig filterConfig) {}
    @Override public void destroy() {}
}
