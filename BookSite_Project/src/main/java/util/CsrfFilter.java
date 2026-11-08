package util;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** 모든 POST 요청의 CSRF 토큰 검사. ※ 상태를 바꾸는 기능은 반드시 POST로만 받을 것 */
@WebFilter("/*")
public class CsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            if (request.getCharacterEncoding() == null) request.setCharacterEncoding("UTF-8");

            if (!CsrfUtil.isValid(request)) {
                reject(request, response);
                return;
            }
        }
        chain.doFilter(req, res);
    }

    private void reject(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        String msg = "요청이 만료되었거나 올바르지 않습니다. 페이지를 새로고침한 뒤 다시 시도해 주세요.";

        if (request.getHeader(CsrfUtil.HEADER) != null) {
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"ok\":false,\"message\":\"" + msg + "\"}");
            return;
        }
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<script>alert('" + msg + "'); history.back();</script>");
    }

    @Override public void init(FilterConfig filterConfig) {}
    @Override public void destroy() {}
}
