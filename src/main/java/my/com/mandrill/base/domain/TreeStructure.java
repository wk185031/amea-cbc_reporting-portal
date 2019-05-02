package my.com.mandrill.base.domain;

import java.util.ArrayList;
import java.util.List;

public class TreeStructure {
	private Long id;
	private Long actualId;
	private String name;
	private List<TreeStructure> children;

	TreeStructure() {
	}

	public TreeStructure(ReportCategory reportCategory) {
		this.actualId = reportCategory.getId();
		this.name = reportCategory.getName();
	}
	
	public TreeStructure(ReportDefinition reportDefinition) {
		this.actualId = reportDefinition.getId();
		this.name = reportDefinition.getName();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getActualId() {
		return actualId;
	}

	public void setActualId(Long actualId) {
		this.actualId = actualId;
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public List<TreeStructure> getChildren() {
		return children;
	}

	public void setChildren(List<TreeStructure> children) {
		this.children = children;
	}

	public void addChildren(TreeStructure child) {
		if (this.getChildren() == null)
			this.children = new ArrayList<>();
		if (child != null)
			this.children.add(child);
	}

	@Override
	public String toString() {
		return "TreeStructure [id=" + id + ", actualId=" + actualId + ", name=" + name + ", children=" + children + "]";
	}
}
