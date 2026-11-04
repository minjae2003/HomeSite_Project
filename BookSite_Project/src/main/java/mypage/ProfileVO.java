package mypage;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class ProfileVO {
    private String userId;
    private String profileImg;
    private String bio;
    private String region;
    private String livingYears;
    private String tags;

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

    public List<String> getTagList() {
        if (tags == null || tags.trim().isEmpty()) return new ArrayList<String>();
        return new ArrayList<String>(Arrays.asList(tags.split(",")));
    }

    public boolean hasImage() { return profileImg != null && !profileImg.isEmpty(); }
}