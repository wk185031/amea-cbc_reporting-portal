package my.com.mandrill.base.service.dto;

import java.io.Serializable;

public class ChangedItemDTO implements Serializable {

	private static final long serialVersionUID = 1L;

	private String name;

	private String from;

	private String to;

	public ChangedItemDTO(String name, String from, String to) {
		this.name = name;
		this.from = from;
		this.to = to;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getFrom() {
		return from;
	}

	public void setFrom(String from) {
		this.from = from;
	}

	public String getTo() {
		return to;
	}

	public void setTo(String to) {
		this.to = to;
	}

}
