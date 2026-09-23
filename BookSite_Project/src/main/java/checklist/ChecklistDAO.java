package checklist;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * 자취 시작 체크리스트 - 계정별 체크 상태 저장/조회
 * 테이블: USER_CHECKLIST (checklist_table.sql 참고)
 * 체크 상태는 체크된 항목 키만 콤마로 이어서 저장 (예: "c0_0,c1_3,c2_5")
 */
public class ChecklistDAO {

    /** 로그인 시 세션에 사용자 ID를 넣는 이름 — 프로젝트 로그인 처리와 반드시 맞출 것 */
    public static final String SESSION_USER_KEY = "userId";

    /** 체크박스 키 형식: c{카테고리번호}_{항목번호} */
    private static final Pattern KEY_PATTERN = Pattern.compile("^c\\d{1,2}_\\d{1,2}$");

    public static boolean isValidKey(String key) {
        return key != null && KEY_PATTERN.matcher(key).matches();
    }

    /**
     * TODO: 프로젝트에서 이미 쓰고 있는 DB 연결 방식(DBUtil, JNDI 커넥션 풀 등)으로 교체하세요.
     */
    private Connection getConnection() throws Exception {
        // Oracle
        Class.forName("oracle.jdbc.OracleDriver");
        return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "USER", "PASSWORD");

        // MySQL 이라면:
        // Class.forName("com.mysql.cj.jdbc.Driver");
        // return DriverManager.getConnection(
        //     "jdbc:mysql://localhost:3306/DB이름?serverTimezone=Asia/Seoul&characterEncoding=UTF-8",
        //     "USER", "PASSWORD");
    }

    /**
     * 계정에 저장된 체크 키 목록을 불러온다.
     * @return 저장 기록이 없으면 null, 있으면 키 목록(0개일 수 있음)
     */
    public Set<String> loadKeys(String userId) throws Exception {
        String sql = "SELECT CHECKED_KEYS FROM USER_CHECKLIST WHERE USER_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                Set<String> keys = new LinkedHashSet<>();
                String raw = rs.getString(1);   // Oracle은 빈 문자열을 NULL로 저장함
                if (raw != null && !raw.isEmpty()) {
                    for (String k : raw.split(",")) {
                        k = k.trim();
                        if (isValidKey(k)) keys.add(k);
                    }
                }
                return keys;
            }
        }
    }

    /**
     * 체크 상태를 저장한다. (기존 행이 있으면 UPDATE, 없으면 INSERT)
     */
    public void saveKeys(String userId, Collection<String> keys, int totalCount) throws Exception {
        String joined = String.join(",", keys);

        String updateSql = "UPDATE USER_CHECKLIST "
                         + "SET CHECKED_KEYS = ?, CHECKED_CNT = ?, TOTAL_CNT = ?, UPDATED_AT = CURRENT_TIMESTAMP "
                         + "WHERE USER_ID = ?";
        String insertSql = "INSERT INTO USER_CHECKLIST (USER_ID, CHECKED_KEYS, CHECKED_CNT, TOTAL_CNT, UPDATED_AT) "
                         + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, joined);
                    ps.setInt(2, keys.size());
                    ps.setInt(3, totalCount);
                    ps.setString(4, userId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setString(1, userId);
                        ps.setString(2, joined);
                        ps.setInt(3, keys.size());
                        ps.setInt(4, totalCount);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }
}
