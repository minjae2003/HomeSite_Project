package mypage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/**
 * 프로필 편집 (MEMBER_PROFILE 테이블) 조회/저장 + 선택지 목록
 * 선택지(지역/연차/태그)는 서버에서도 이 목록으로 검사한다.
 */
public class ProfileDAO {
    private static ProfileDAO instance = new ProfileDAO();
    public static ProfileDAO getInstance() { return instance; }
    private ProfileDAO() {}

    public static final int BIO_MAX = 40;
    public static final int TAG_MAX = 5;

    /** 자취 연차 선택지 ("" = 설정 안 함) */
    public static final List<String> YEARS = Arrays.asList("1년 미만", "1~3년", "4~9년", "10년 이상");

    /** 관심 태그 선택지 */
    public static final List<String> TAGS = Arrays.asList("청소", "요리", "원룸", "인테리어", "자취템", "전세계약", "야식", "반려동물");

    /** 거주 지역 선택지: 시·도별 도시 목록 (특별시·광역시·특별자치시 + 도 소속 시 전체) */
    public static final Map<String, List<String>> REGIONS = new LinkedHashMap<String, List<String>>();
    static {
        REGIONS.put("특별시·광역시", Arrays.asList(
            "서울특별시", "부산광역시", "대구광역시", "인천광역시", "광주광역시",
            "대전광역시", "울산광역시", "세종특별자치시"));
        REGIONS.put("경기도", withProvince("경기도",
            "수원시", "성남시", "의정부시", "안양시", "부천시", "광명시", "평택시", "동두천시",
            "안산시", "고양시", "과천시", "구리시", "남양주시", "오산시", "시흥시", "군포시",
            "의왕시", "하남시", "용인시", "파주시", "이천시", "안성시", "김포시", "화성시",
            "광주시", "양주시", "포천시", "여주시"));
        REGIONS.put("강원특별자치도", withProvince("강원특별자치도",
            "춘천시", "원주시", "강릉시", "동해시", "태백시", "속초시", "삼척시"));
        REGIONS.put("충청북도", withProvince("충청북도", "청주시", "충주시", "제천시"));
        REGIONS.put("충청남도", withProvince("충청남도",
            "천안시", "공주시", "보령시", "아산시", "서산시", "논산시", "계룡시", "당진시"));
        REGIONS.put("전북특별자치도", withProvince("전북특별자치도",
            "전주시", "군산시", "익산시", "정읍시", "남원시", "김제시"));
        REGIONS.put("전라남도", withProvince("전라남도", "목포시", "여수시", "순천시", "나주시", "광양시"));
        REGIONS.put("경상북도", withProvince("경상북도",
            "포항시", "경주시", "김천시", "안동시", "구미시", "영주시", "영천시", "상주시", "문경시", "경산시"));
        REGIONS.put("경상남도", withProvince("경상남도",
            "창원시", "진주시", "통영시", "사천시", "김해시", "밀양시", "거제시", "양산시"));
        REGIONS.put("제주특별자치도", withProvince("제주특별자치도", "제주시", "서귀포시"));
    }

    /** "경상남도" + "양산시" → "경상남도 양산시" 형태로 저장, 도마다 군 지역 선택지도 추가 */
    private static List<String> withProvince(String province, String... cities) {
        String[] full = new String[cities.length + 1];
        for (int i = 0; i < cities.length; i++) full[i] = province + " " + cities[i];
        full[cities.length] = province + " 군 지역";
        return Arrays.asList(full);
    }

    public static boolean isValidRegion(String region) {
        for (List<String> list : REGIONS.values()) if (list.contains(region)) return true;
        return false;
    }

    /** 선택지 표시용: "경상남도 양산시" → "양산시" (특별시·광역시는 그대로) */
    public static String shortRegion(String region) {
        if (region == null) return "";
        int sp = region.indexOf(' ');
        return sp < 0 ? region : region.substring(sp + 1);
    }

    private Connection getConnection() throws Exception {
        Context initCtx = new InitialContext();
        Context envCtx = (Context) initCtx.lookup("java:comp/env");
        DataSource ds = (DataSource) envCtx.lookup("jdbc/homesiteproject");
        return ds.getConnection();
    }

    /** 프로필 조회 - 저장된 적이 없으면 빈 프로필(모두 설정 안 함) */
    public ProfileVO get(String userId) {
        ProfileVO vo = new ProfileVO();
        vo.setUserId(userId);
        if (userId == null) return vo;
        String sql = "SELECT profile_img, bio, region, living_years, tags FROM MEMBER_PROFILE WHERE user_id = ?";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                vo.setProfileImg(rs.getString("profile_img"));
                vo.setBio(rs.getString("bio"));
                vo.setRegion(rs.getString("region"));
                vo.setLivingYears(rs.getString("living_years"));
                vo.setTags(rs.getString("tags"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, rs);
        }
        return vo;
    }

    /** 프로필 저장 (없으면 새로 만들고, 있으면 덮어씀) */
    public boolean save(ProfileVO vo) {
        String sql = "INSERT INTO MEMBER_PROFILE (user_id, profile_img, bio, region, living_years, tags) "
                   + "VALUES (?, ?, ?, ?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE profile_img = VALUES(profile_img), bio = VALUES(bio), "
                   + "region = VALUES(region), living_years = VALUES(living_years), tags = VALUES(tags)";
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, vo.getUserId());
            pstmt.setString(2, emptyToNull(vo.getProfileImg()));
            pstmt.setString(3, emptyToNull(vo.getBio()));
            pstmt.setString(4, emptyToNull(vo.getRegion()));
            pstmt.setString(5, emptyToNull(vo.getLivingYears()));
            pstmt.setString(6, emptyToNull(vo.getTags()));
            return pstmt.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            close(conn, pstmt, null);
        }
        return false;
    }

    private static String emptyToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s;
    }

    private void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}