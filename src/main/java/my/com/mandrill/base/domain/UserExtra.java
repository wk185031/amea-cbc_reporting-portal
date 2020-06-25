package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

/**
 * Custom entity to extend the built-in User entity.
 * name: copy of first name + last name from User entity
 */
@ApiModel(description = "Custom entity to extend the built-in User entity. name: copy of first name + last name from User entity")
@Entity
@Table(name = "user_extra")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "userextra")
public class UserExtra extends AbstractAuditingEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Size(max = 100)
    @Column(name = "name", length = 100, nullable = false)
    private String name;

    @Size(max = 50)
    @Column(name = "designation", length = 50)
    private String designation;

    @Size(max = 20)
    @Column(name = "contact_mobile", length = 20)
    private String contactMobile;

    @Size(max = 20)
    @Column(name = "contact_work", length = 20)
    private String contactWork;

    @Size(max = 20)
    @Column(name = "contact_other", length = 20)
    private String contactOther;

    @OneToOne(optional = false)
    @NotNull
    @JoinColumn(unique = true)
    private User user;

    @ManyToMany(fetch = FetchType.EAGER)
    @Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
    @NotNull
    @JoinTable(name = "user_extra_roles",
               joinColumns = @JoinColumn(name="user_extras_id", referencedColumnName="id"),
               inverseJoinColumns = @JoinColumn(name="roles_id", referencedColumnName="id"))
    private Set<RoleExtra> roles = new HashSet<>();

    @ManyToMany(fetch = FetchType.EAGER)
    @Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
    @NotNull
    @JoinTable(name = "user_extra_institutions",
               joinColumns = @JoinColumn(name="user_extras_id", referencedColumnName="id"),
               inverseJoinColumns = @JoinColumn(name="institutions_id", referencedColumnName="id"))
    private Set<Institution> institutions = new HashSet<>();
    
    @ManyToMany(fetch = FetchType.EAGER)
    @Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
    @NotNull
    @JoinTable(name = "user_extra_branches",
               joinColumns = @JoinColumn(name="user_extra_id", referencedColumnName="id"),
               inverseJoinColumns = @JoinColumn(name="branch_id", referencedColumnName="abr_id"))
    private Set<Branch> branches = new HashSet<>();

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

    public UserExtra name(String name) {
        this.name = name;
        return this;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDesignation() {
        return designation;
    }

    public UserExtra designation(String designation) {
        this.designation = designation;
        return this;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public String getContactMobile() {
        return contactMobile;
    }

    public UserExtra contactMobile(String contactMobile) {
        this.contactMobile = contactMobile;
        return this;
    }

    public void setContactMobile(String contactMobile) {
        this.contactMobile = contactMobile;
    }

    public String getContactWork() {
        return contactWork;
    }

    public UserExtra contactWork(String contactWork) {
        this.contactWork = contactWork;
        return this;
    }

    public void setContactWork(String contactWork) {
        this.contactWork = contactWork;
    }

    public String getContactOther() {
        return contactOther;
    }

    public UserExtra contactOther(String contactOther) {
        this.contactOther = contactOther;
        return this;
    }

    public void setContactOther(String contactOther) {
        this.contactOther = contactOther;
    }

    public User getUser() {
        return user;
    }

    public UserExtra user(User user) {
        this.user = user;
        return this;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Set<RoleExtra> getRoles() {
        return roles;
    }

    public UserExtra roles(Set<RoleExtra> roleExtras) {
        this.roles = roleExtras;
        return this;
    }

    public UserExtra addRoles(RoleExtra roleExtra) {
        this.roles.add(roleExtra);
        return this;
    }

    public UserExtra removeRoles(RoleExtra roleExtra) {
        this.roles.remove(roleExtra);
        return this;
    }

    public void setRoles(Set<RoleExtra> roleExtras) {
        this.roles = roleExtras;
    }

    public Set<Institution> getInstitutions() {
        return institutions;
    }

    public UserExtra institutions(Set<Institution> institutions) {
        this.institutions = institutions;
        return this;
    }

    public UserExtra addInstitutions(Institution institution) {
        this.institutions.add(institution);
        return this;
    }

    public UserExtra removeInstitutions(Institution institution) {
        this.institutions.remove(institution);
        return this;
    }

    public void setInstitutions(Set<Institution> institutions) {
        this.institutions = institutions;
    }
    // jhipster-needle-entity-add-getters-setters - JHipster will add getters and setters here, do not remove

    public Set<Branch> getBranches() {
		return branches;
	}

	public void setBranches(Set<Branch> branches) {
		this.branches = branches;
	}

	@Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        UserExtra userExtra = (UserExtra) o;
        if (userExtra.getId() == null || getId() == null) {
            return false;
        }
        return Objects.equals(getId(), userExtra.getId());
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(getId());
    }

    @Override
    public String toString() {
        return "UserExtra{" +
            "id=" + getId() +
            ", name='" + getName() + "'" +
            ", designation='" + getDesignation() + "'" +
            ", contactMobile='" + getContactMobile() + "'" +
            ", contactWork='" + getContactWork() + "'" +
            ", contactOther='" + getContactOther() + "'" +
            ", createdBy='" + getCreatedBy() + "'" +
            ", createdDate='" + getCreatedDate() + "'" +
            ", lastModifiedBy='" + getLastModifiedBy() + "'" +
            ", lastModifiedDate='" + getLastModifiedDate() + "'" +
            "}";
    }
}
