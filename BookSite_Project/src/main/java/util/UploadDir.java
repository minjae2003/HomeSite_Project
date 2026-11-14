package util;

import java.io.File;

import javax.servlet.ServletContext;

/**
 * 업로드 파일 저장 폴더.
 * 서버에서는 환경변수 HOMESITE_UPLOAD_DIR(웹앱 밖 폴더)를 사용해 재배포해도 파일이 지워지지 않게 한다.
 * 설정이 없으면(로컬 Eclipse) 기존처럼 웹앱 안의 /uploads 를 사용한다.
 */
public final class UploadDir {
    private UploadDir() {}

    public static File root(ServletContext ctx) {
        String p = System.getProperty("homesite.upload.dir");
        if (p == null || p.trim().isEmpty()) p = System.getenv("HOMESITE_UPLOAD_DIR");
        if (p == null || p.trim().isEmpty()) p = ctx.getRealPath("/uploads");
        File dir = new File(p.trim());
        if (!dir.exists()) dir.mkdirs();
        return dir;
    }

    public static File profile(ServletContext ctx) {
        File dir = new File(root(ctx), "profile");
        if (!dir.exists()) dir.mkdirs();
        return dir;
    }
}
