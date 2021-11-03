package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.DcmsUserActivity;

@Repository
public interface DcmsUserActivityRepository extends JpaRepository<DcmsUserActivity, Long> {

}
