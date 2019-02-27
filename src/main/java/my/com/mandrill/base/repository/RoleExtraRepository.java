package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.RoleExtra;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import java.util.List;

/**
 * Spring Data JPA repository for the RoleExtra entity.
 */
@SuppressWarnings("unused")
@Repository
public interface RoleExtraRepository extends JpaRepository<RoleExtra, Long> {
    @Query("select distinct role_extra from RoleExtra role_extra left join fetch role_extra.permissions")
    List<RoleExtra> findAllWithEagerRelationships();

    @Query("select role_extra from RoleExtra role_extra left join fetch role_extra.permissions where role_extra.id =:id")
    RoleExtra findOneWithEagerRelationships(@Param("id") Long id);

    @Query("select role_extra from RoleExtra role_extra left join fetch role_extra.permissions where role_extra.name =:name")
    RoleExtra findOneWithEagerRelationships(@Param("name") String name);
}
