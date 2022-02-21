package my.com.mandrill.base.service.dto;


import java.time.Instant;

import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;

/**
 * A DTO representing a user extra.
 */
public class UserExtraDTO {

    private Long id;

    private String name;

    private String contactMobile;

    private User user;

    private String createdBy;

    private Instant createdDate;

    private String lastModifiedBy;

    private Instant lastModifiedDate;

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

    public String getContactMobile() {
        return contactMobile;
    }

    public void setContactMobile(String contactMobile) {
        this.contactMobile = contactMobile;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public Instant getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Instant createdDate) {
        this.createdDate = createdDate;
    }

    public String getLastModifiedBy() {
        return lastModifiedBy;
    }

    public void setLastModifiedBy(String lastModifiedBy) {
        this.lastModifiedBy = lastModifiedBy;
    }

    public Instant getLastModifiedDate() {
        return lastModifiedDate;
    }

    public void setLastModifiedDate(Instant lastModifiedDate) {
        this.lastModifiedDate = lastModifiedDate;
    }

    public UserExtraDTO() {
        // Empty constructor needed for Jackson.
    }

    public UserExtraDTO(UserExtra userExtra) {
        this.id = userExtra.getId();
        this.contactMobile = userExtra.getContactMobile();
        this.user = userExtra.getUser();
        this.createdBy = userExtra.getCreatedBy();
        this.createdDate = userExtra.getCreatedDate();
        this.lastModifiedBy = userExtra.getLastModifiedBy();
        this.lastModifiedDate = userExtra.getLastModifiedDate();
    }

    @Override
    public String toString() {
        return "UserExtraDTO{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", contactMobile='" + contactMobile + '\'' +
            ", user=" + user +
            ", createdBy='" + createdBy + '\'' +
            ", createdDate=" + createdDate +
            ", lastModifiedBy='" + lastModifiedBy + '\'' +
            ", lastModifiedDate=" + lastModifiedDate +
            '}';
    }
}
