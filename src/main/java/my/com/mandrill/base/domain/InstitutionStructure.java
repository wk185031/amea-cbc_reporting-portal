package my.com.mandrill.base.domain;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by darmawan.fatriananda@mandrill.com.my on 17/9/2017.
 */
public class InstitutionStructure {
    private Long id;
    private String name;
    private List<InstitutionStructure> children;

    InstitutionStructure(){

    }
    public InstitutionStructure(Institution c){
        this.id = c.getId();
        this.name = c.getName();
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


    public void addChildren(InstitutionStructure child){
        if(this.getChildren() ==null)
            this.children = new ArrayList<>();
        if(child!=null)
            this.children.add(child);
    }

    public List<InstitutionStructure> getChildren() {
        return children;
    }

    public void setChildren(List<InstitutionStructure> children) {
        this.children = children;
    }
    @Override
    public String toString() {
        return "{id:" + this.id + ", name:" + name + ",  children:[" +this.children + "]}";
    }
}
