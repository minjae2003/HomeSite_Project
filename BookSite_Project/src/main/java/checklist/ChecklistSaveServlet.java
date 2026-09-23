package checklist;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.Set;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 체크리스트 계정 저장 요청 처리
 * POST /checklist/save
 *   keys  : 체크된 항목 키 (여러 개, 예: keys=c0_0&keys=c1_3)
 *   total : 전체 항목 수
 * 응답: {"ok":true,"checked":N} / 실패 시 {"ok":false,"message":"..."}
 */
@WebServlet("/checklist/save")
public class ChecklistSaveServlet extends HttpServlet {

    private static final int MAX_KEYS = 200;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        // 1) 로그인 확인
        HttpSession session = req.getSession(false);
        Object loginObj = (session == null) ? null : session.getAttribute(ChecklistDAO.SESSION_USER_KEY);
        String userId = (loginObj == null) ? null : loginObj.toString();
        if (userId == null || userId.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"ok\":false,\"message\":\"login required\"}");
            return;
        }

        // 2) 파라미터 검증 (형식이 맞는 키만 저장)
        Set<String> keys = new LinkedHashSet<>();
        String[] params = req.getParameterValues("keys");   // 체크된 게 없으면 null
        if (params != null) {
            for (String k : params) {
                if (ChecklistDAO.isValidKey(k)) keys.add(k);
                if (keys.size() >= MAX_KEYS) break;
            }
        }

        int total;
        try {
            total = Integer.parseInt(req.getParameter("total"));
        } catch (Exception e) {
            total = 0;
        }
        if (total < keys.size() || total > MAX_KEYS) total = keys.size();

        // 3) 저장
        try {
            new ChecklistDAO().saveKeys(userId, keys, total);
            resp.getWriter().write("{\"ok\":true,\"checked\":" + keys.size() + "}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"ok\":false,\"message\":\"server error\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
