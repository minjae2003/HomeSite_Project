package member;

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
import javax.servlet.http.HttpSession;

import util.SiteInfo;

@WebFilter("/*")
public class ConsentFilter implements Filter {

    private static final String[] OPEN_PREFIX = { "/policy/", "/error/" };
    private static final String[] OPEN_PAGE = { "/member/LogoutPro.jsp", "/mypage/account.jsp" };

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if (needsConsent(request)) {
            response.sendRedirect(request.getContextPath() + "/policy/consent.jsp");
            return;
        }
        chain.doFilter(req, res);
    }

    private boolean needsConsent(HttpServletRequest request) {
        if (!"GET".equalsIgnoreCase(request.getMethod())) return false;

        String path = request.getRequestURI().substring(request.getContextPath().length());
        if (!(path.endsWith(".jsp") || path.endsWith("/"))) return false;
        for (String p : OPEN_PREFIX) if (path.startsWith(p)) return false;
        for (String p : OPEN_PAGE) if (path.equals(p)) return false;

        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String id = (String) session.getAttribute("id");
        if (id == null) return false;
        if (SiteInfo.POLICY_VERSION.equals(session.getAttribute(ConsentDAO.SESSION_KEY))) return false;

        Boolean agreed = ConsentDAO.getInstance().hasAgreed(id, SiteInfo.POLICY_VERSION);
        if (agreed == null) return false;
        if (agreed) {
            session.setAttribute(ConsentDAO.SESSION_KEY, SiteInfo.POLICY_VERSION);
            return false;
        }
        return true;
    }

    @Override public void init(FilterConfig filterConfig) {}
    @Override public void destroy() {}
}
