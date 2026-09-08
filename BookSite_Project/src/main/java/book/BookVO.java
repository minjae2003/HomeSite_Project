package book;

import java.sql.Timestamp;

public class BookVO {

    private int bnum;
    private String bkind;
    private String btitle;
    private String author;
    private String pubcom;
    private Timestamp pubdate;
    private int page;
    private String bimage;     
    private String bcontent;
    
	public int getBnum() {
		return bnum;
	}
	public void setBnum(int bnum) {
		this.bnum = bnum;
	}
	public String getBkind() {
		return bkind;
	}
	public void setBkind(String bkind) {
		this.bkind = bkind;
	}
	public String getBtitle() {
		return btitle;
	}
	public void setBtitle(String btitle) {
		this.btitle = btitle;
	}
	public String getAuthor() {
		return author;
	}
	public void setAuthor(String author) {
		this.author = author;
	}
	public String getPubcom() {
		return pubcom;
	}
	public void setPubcom(String pubcom) {
		this.pubcom = pubcom;
	}
	public Timestamp getPubdate() {
		return pubdate;
	}
	public void setPubdate(Timestamp pubdate) {
		this.pubdate = pubdate;
	}
	public int getPage() {
		return page;
	}
	public void setPage(int page) {
		this.page = page;
	}
	public String getBimage() {
		return bimage;
	}
	public void setBimage(String bimage) {
		this.bimage = bimage;
	}
	public String getBcontent() {
		return bcontent;
	}
	public void setBcontent(String bcontent) {
		this.bcontent = bcontent;
	}
    
}
