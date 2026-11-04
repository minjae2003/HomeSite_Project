package upload;

import java.sql.Timestamp;

public class BoardFileVO {
    private int fileNum;
    private int boardNum;
    private String originalName;
    private String savedName;
    private String fileType;
    private long fileSize;
    private int uploadOrder;
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

    public String getWebPath() {
        return "/uploads/" + savedName;
    }

    public boolean isImage() { return "IMAGE".equals(fileType); }
    public boolean isVideo() { return "VIDEO".equals(fileType); }
    public boolean isFile() { return "FILE".equals(fileType); }
}