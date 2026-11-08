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

@WebServlet("/sitemap.xml")
public class SitemapServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
