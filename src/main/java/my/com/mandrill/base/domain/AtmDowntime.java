package my.com.mandrill.base.domain;

import java.sql.Date;
import java.sql.Timestamp;

public class AtmDowntime {

	private Long astId;
	
	private Date statusDate;
	
	private Timestamp startTimestamp;
	
	private Timestamp endTimestamp;
	
	private String downReason;
	
	public AtmDowntime(Long astId, Date statusDate, Timestamp startTimestamp, Timestamp endTimestamp, String downReason) {
		this.astId = astId;
		this.statusDate = statusDate;
		this.startTimestamp = startTimestamp;
		this.endTimestamp = endTimestamp;
		this.downReason = downReason;
	}

	public Long getAstId() {
		return astId;
	}

	public void setAstId(Long astId) {
		this.astId = astId;
	}

	public Date getStatusDate() {
		return statusDate;
	}

	public void setStatusDate(Date statusDate) {
		this.statusDate = statusDate;
	}

	public Timestamp getStartTimestamp() {
		return startTimestamp;
	}

	public void setStartTimestamp(Timestamp startTimestamp) {
		this.startTimestamp = startTimestamp;
	}

	public Timestamp getEndTimestamp() {
		return endTimestamp;
	}

	public void setEndTimestamp(Timestamp endTimestamp) {
		this.endTimestamp = endTimestamp;
	}

	public String getDownReason() {
		return downReason;
	}

	public void setDownReason(String downReason) {
		this.downReason = downReason;
	}

	public boolean isRepeatedEntry(Long astId, Date businessDate, boolean isDown) {
		if (isDown) {
			return this.astId.equals(astId) && this.statusDate.equals(businessDate) && this.endTimestamp == null;
		} else { 
			return this.astId.equals(astId) && this.statusDate.equals(businessDate) && this.endTimestamp != null;
		}
	}
	
	public AtmDowntime clone() {
		return new AtmDowntime(this.astId, this.statusDate, this.startTimestamp, this.endTimestamp, this.downReason);
	}

}
