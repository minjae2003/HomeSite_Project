package upload;

import java.sql.Timestamp;

public class BoardFileVO {
    private int fileNum;
    private int boardNum;
    private String originalName;   // 사용자가 올린 원래 파일명
    private String savedName;      // 서버에 저장된 파일명 (중복 방지용 UUID)
    private String fileType;       // IMAGE / VIDEO
    private long fileSize;
    private int uploadOrder;       // 본문 [img1], [video1] 매칭 순서
    private Timestamp regDate;

    public int getFileNum() { return fileNum; }
    public void setFileNum(int fileNum) { this.fileNum = fileNum; }

    public int getBoardNum() { return boardNum; }
    public void setBoardNum(int boardNum) { this.boardNum = boardNum; }

    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }

    public String getSavedName() { return savedName; }
    public void setSavedName(String savedName) { this.savedName = savedName; }

    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public int getUploadOrder() { return uploadOrder; }
    public void setUploadOrder(int uploadOrder) { this.uploadOrder = uploadOrder; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }

    // 컨텍스트 경로 기준 정적 서빙 경로 (webapp/uploads 에 저장되고 톰캣이 그대로 서빙)
    public String getWebPath() {
        return "/uploads/" + savedName;
    }

    public boolean isImage() { return "IMAGE".equals(fileType); }
    public boolean isVideo() { return "VIDEO".equals(fileType); }
    public boolean isFile() { return "FILE".equals(fileType); }
}