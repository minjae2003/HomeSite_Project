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

/**
 * 모든 POST 요청의 CSRF 토큰을 검사하는 필터.
 * 토큰이 없거나 틀리면 처리 페이지(JSP/서블릿)까지 가지 않고 403으로 막는다.
 *
 * ※ 상태를 바꾸는 기능(삭제, 추천, 글쓰기 등)은 반드시 POST로만 받아야 이 필터의 보호를 받는다.
 */
@WebFilter("/*")
public class CsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            // 한글 파라미터가 깨지지 않도록, 파라미터를 처음 읽기 전에 인코딩 지정
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
