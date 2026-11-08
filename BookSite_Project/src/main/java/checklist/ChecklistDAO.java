package checklist;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Pattern;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class ChecklistDAO {

    public static final String SESSION_USER_KEY = "id";

    private static final Pattern KEY_PATTERN = Pattern.compile("^c\\d{1,2}_\\d{1,2}$");

    public static boolean isValidKey(String key) {
        return key != null && KEY_PATTERN.matcher(key).matches();
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    public Set<String> loadKeys(String userId) throws Exception {
        String sql = "SELECT CHECKED_KEYS FROM USER_CHECKLIST WHERE USER_ID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                Set<String> keys = new LinkedHashSet<>();
                String raw = rs.getString(1);
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