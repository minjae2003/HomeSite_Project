package visit;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 실제 사람 방문만 세기.
 * 페이지를 연 브라우저가 스크롤·클릭·터치를 하거나 4초 이상 화면을 띄워 두면 header.jsp의 스크립트가 이 주소로 신호를 보낸다.
 * HTML만 가져가는 봇은 스크립트를 실행하지 않고, 쿠키를 저장하지 않는 봇은 세션이 이어지지 않아 자연스럽게 빠진다.
 * 봇 이름(User-Agent)·관리자 계정·Accept-Language 없는 요청도 제외.
 */
@WebServlet("/visit")
public class VisitServlet extends HttpServlet {
    public static final String COUNTED = "VISIT_COUNTED_DATE";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        HttpSession session = request.getSession(false);
        if (session == null || session.isNew()) return;           // 쿠키를 돌려보내지 않은 요청
        if ("ADMIN".equals(session.getAttribute("role"))) return;  // 운영자 본인 제외
        if (seo.SiteUrl.isBot(request)) return;
        String lang = request.getHeader("Accept-Language");
        if (lang == null || lang.trim().isEmpty()) return;

        String today = VisitDAO.today();
        if (today.equals(session.getAttribute(COUNTED))) return;
        session.setAttribute(COUNTED, today);
        VisitDAO.getInstance().recordVisit(session.getId());
    }

    /** 오늘 이미 센 세션이면 true (header.jsp가 스크립트를 넣을지 판단) */
    public static boolean countedToday(HttpSession session) {
        return session != null && VisitDAO.today().equals(session.getAttribute(COUNTED));
    }
}
