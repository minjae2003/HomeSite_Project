package mypage;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** 회원 공개 프로필 (MEMBER_PROFILE 테이블) - 값이 없으면 "설정 안 함" */
public class ProfileVO {
    private String userId;
    private String profileImg;   // uploads/profile/ 안의 저장 파일명
    private String bio;          // 한줄 소개 (최대 40자)
    private String region;       // 거주 지역 (예: "경상남도 양산시")
    private String livingYears;  // 자취 연차 (예: "1~3년")
    private String tags;         // 관심 태그, 콤마로 구분 (예: "청소,요리")

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getProfileImg() { return profileImg; }
    public void setProfileImg(String profileImg) { this.profileImg = profileImg; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public String getLivingYears() { return livingYears; }
    public void setLivingYears(String livingYears) { this.livingYears = livingYears; }

    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }

    /** 관심 태그 목록 */
    public List<String> getTagList() {
        if (tags == null || tags.trim().isEmpty()) return new ArrayList<String>();
        return new ArrayList<String>(Arrays.asList(tags.split(",")));
    }

    public boolean hasImage() { return profileImg != null && !profileImg.isEmpty(); }
}