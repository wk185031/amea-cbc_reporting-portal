package my.com.mandrill.base.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

import io.swagger.annotations.ApiModel;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import javax.persistence.*;
import javax.validation.constraints.*;

import org.springframework.data.elasticsearch.annotations.Document;
import java.io.Serializable;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Objects;

/**
 * Institution, to support multi-institutions system
 */
@ApiModel(description = "Institution, to support multi-institutions system")
@Entity
@Table(name = "institution")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "institution")
public class Institution extends AbstractAuditingEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Size(max = 50)
    @Column(name = "name", length = 50, nullable = false)
    private String name;

    @Size(max = 50)
    @Column(name = "jhi_type", length = 50)
    private String type;

    @Size(max = 50)
    @Column(name = "business_reg_no", length = 50)
    private String businessRegNo;

    @Size(max = 50)
    @Column(name = "industry", length = 50)
    private String industry;

    @Size(max = 500)
    @Column(name = "address", length = 500)
    private String address;

    @Size(max = 50)
    @Column(name = "phone", length = 50)
    private String phone;

    @Size(max = 50)
    @Column(name = "fax", length = 50)
    private String fax;

    @Size(max = 50)
    @Column(name = "email", length = 50)
    private String email;

    @Size(max = 50)
    @Column(name = "website", length = 50)
    private String website;

    @OneToOne
    @JoinColumn(unique = true)
    private AttachmentGroup attachmentGroup;

    @ManyToOne
    private Institution parent;

    @Transient
    @JsonSerialize
    @JsonDeserialize
    private List<Institution> children;

    @Transient
    @JsonSerialize
    @JsonDeserialize
//    @OneToMany(mappedBy = "institution")
    private Set<Attachment> attachments = new HashSet<>();

    // jhipster-needle-entity-add-field - JHipster will add fields here, do not remove
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public Institution name(String name) {
        this.name = name;
        return this;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public Institution type(String type) {
        this.type = type;
        return this;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getBusinessRegNo() {
        return businessRegNo;
    }

    public Institution businessRegNo(String businessRegNo) {
        this.businessRegNo = businessRegNo;
        return this;
    }

    public void setBusinessRegNo(String businessRegNo) {
        this.businessRegNo = businessRegNo;
    }

    public String getIndustry() {
        return industry;
    }

    public Institution industry(String industry) {
        this.industry = industry;
        return this;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getAddress() {
        return address;
    }

    public Institution address(String address) {
        this.address = address;
        return this;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhone() {
        return phone;
    }

    public Institution phone(String phone) {
        this.phone = phone;
        return this;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getFax() {
        return fax;
    }

    public Institution fax(String fax) {
        this.fax = fax;
        return this;
    }

    public void setFax(String fax) {
        this.fax = fax;
    }

    public String getEmail() {
        return email;
    }

    public Institution email(String email) {
        this.email = email;
        return this;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getWebsite() {
        return website;
    }

    public Institution website(String website) {
        this.website = website;
        return this;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public List<Institution> getChildren() {
		return children;
	}

	public void setChildren(List<Institution> children) {
		this.children = children;
	}

	public Institution getParent() {
        return parent;
    }

    public Institution parent(Institution institution) {
        this.parent = institution;
        return this;
    }

    public void setParent(Institution institution) {
        this.parent = institution;
    }

    public AttachmentGroup getAttachmentGroup() {
        return attachmentGroup;
    }

    public Institution attachmentGroup(AttachmentGroup attachmentGroup) {
        this.attachmentGroup = attachmentGroup;
        return this;
    }

    public void setAttachmentGroup(AttachmentGroup attachmentGroup) {
        this.attachmentGroup = attachmentGroup;
    }
    // jhipster-needle-entity-add-getters-setters - JHipster will add getters and setters here, do not remove

    public Set<Attachment> getAttachments() {
        return attachments;
    }

    public Institution attachments(Set<Attachment> attachments) {
        this.attachments = attachments;
        return this;
    }

    public void setAttachments(Set<Attachment> attachments) {
        this.attachments = attachments;
    }

    public void addChildren(Institution child){
        if(this.getChildren() ==null)
            this.setChildren(new ArrayList<>());
        if(child!=null)
            this.getChildren().add(child);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Institution institution = (Institution) o;
        if (institution.getId() == null || getId() == null) {
            return false;
        }
        return Objects.equals(getId(), institution.getId());
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(getId());
    }

    @Override
    public String toString() {
        return "Institution{" +
            "id=" + getId() +
            ", name='" + getName() + "'" +
            ", type='" + getType() + "'" +
            ", businessRegNo='" + getBusinessRegNo() + "'" +
            ", industry='" + getIndustry() + "'" +
            ", address='" + getAddress() + "'" +
            ", phone='" + getPhone() + "'" +
            ", fax='" + getFax() + "'" +
            ", email='" + getEmail() + "'" +
            ", website='" + getWebsite() + "'" +
            ", createdBy='" + getCreatedBy() + "'" +
            ", createdDate='" + getCreatedDate() + "'" +
            ", lastModifiedBy='" + getLastModifiedBy() + "'" +
            ", lastModifiedDate='" + getLastModifiedDate() + "'" +
            "}";
    }
}
