package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.UserExtra;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;

/**
 * Spring Data JPA repository for the UserExtra entity.
 */
@SuppressWarnings("unused")
@Repository
public interface UserExtraRepository extends JpaRepository<UserExtra, Long> {
    @Query("select distinct user_extra from UserExtra user_extra left join fetch user_extra.roles left join fetch user_extra.institutions")
    List<UserExtra> findAllWithEagerRelationships();

    @Query("select user_extra from UserExtra user_extra left join fetch user_extra.roles left join fetch user_extra.institutions where user_extra.id =:id")
    UserExtra findOneWithEagerRelationships(@Param("id") Long id);

    @Query("select user_extra from UserExtra user_extra left join fetch user_extra.roles u left join fetch user_extra.institutions r where r.id =:institutionId and u.name =:rolesName")
	List<UserExtra> findByRolesAndInstituionId(@Param("rolesName") String rolesName, @Param("institutionId") Long institutionId);
	
	@Query("select ue from UserExtra ue left join fetch ue.user u where u.id =:userId")
	UserExtra findByUser(@Param("userId") Long userId);
    
	List<UserExtra> findByUserLogin(String username);
	
	List<UserExtra> findAllByLastLoginTsIsNotNull();
}
