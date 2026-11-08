package seo;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import board.BoardDAO;
import board.BoardVO;

/**
 * https://jachiclass.com/sitemap.xml
 * 검색엔진(구글, 네이버)에 제출하는 사이트맵. 요청이 올 때마다 DB에서 글 목록을 읽어 만들므로
 * 새 글을 쓰거나 지워도 따로 손댈 필요가 없다.
 * 로그인/회원정보/글쓰기/관리자 페이지는 넣지 않는다.
 */
@WebServlet("/sitemap.xml")
public class SitemapServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 사이트맵 1개에 최대 50,000개 주소까지 가능 → 고정 페이지 몫을 빼고 여유 있게
    private static final int MAX_ARTICLES = 49000;

    private static final String[] STATIC_PAGES = {
        "/main/index.jsp",
        "/freeboard/list.jsp",
        "/freeboard/list.jsp?category=TIP",
        "/freeboard/list.jsp?category=QNA",
        "/freeboard/list.jsp?category=FREE",
        "/freeboard/list.jsp?category=RECIPE",
        "/noticeboard/list.jsp"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        List<BoardVO> articles = BoardDAO.getInstance().getSitemapArticles(MAX_ARTICLES);
        if (articles == null) {
            // DB 오류 시 빈 사이트맵을 주면 검색엔진이 글이 다 없어진 줄 알 수 있으므로 "잠시 후 다시" 응답
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.setHeader("Retry-After", "3600");
            return;
        }

        String base = SiteUrl.base(request);
        SimpleDateFormat day = new SimpleDateFormat("yyyy-MM-dd");

        StringBuilder sb = new StringBuilder(128 + articles.size() * 120);
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        sb.append("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n");
        for (String page : STATIC_PAGES) {
            sb.append("  <url><loc>").append(xml(base + page)).append("</loc></url>\n");
        }
        for (BoardVO a : articles) {
            sb.append("  <url><loc>").append(xml(SiteUrl.articleUrl(request, a.getNum(), a.getCategory()))).append("</loc>");
            if (a.getRegDate() != null) sb.append("<lastmod>").append(day.format(a.getRegDate())).append("</lastmod>");
            sb.append("</url>\n");
        }
        sb.append("</urlset>\n");

        response.setContentType("application/xml; charset=UTF-8");
        response.setHeader("Cache-Control", "public, max-age=3600");
        response.getWriter().write(sb.toString());
    }

    private static String xml(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&apos;");
    }
}
