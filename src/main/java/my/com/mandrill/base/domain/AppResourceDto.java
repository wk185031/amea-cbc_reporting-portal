package my.com.mandrill.base.domain;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class AppResourceDto{
	private Long id;
	private String name;
	private Boolean checked;
	private Boolean indeterminate;
	private List<AppResourceDto> children;
	
	public AppResourceDto(AppResource ar, Set<AppResource> permissionsAllowed){
		this.id = ar.getId();
		this.name = ar.getName();
		this.indeterminate = false;
		if (permissionsAllowed.contains(ar)) {
			this.checked = true;
		} else {
			this.checked = false;
		}
	}
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Boolean getChecked() {
		return checked;
	}
	public void setChecked(Boolean checked) {
		this.checked = checked;
	}
	public List<AppResourceDto> getChildren() {
		return children;
	}
	public void setChildren(List<AppResourceDto> children) {
		this.children = children;
	}

	public void addChildren(AppResourceDto child){
        if(this.getChildren() ==null)
            this.children = new ArrayList<>();
        if(child!=null)
            this.children.add(child);
    }

	public Boolean getIndeterminate() {
		return indeterminate;
	}

	public void setIndeterminate(Boolean indeterminate) {
		this.indeterminate = indeterminate;
	}

	@Override
	public String toString() {
		return "AppResourceDto [id=" + id + ", name=" + name + ", children=" + children + "]";
	}
}