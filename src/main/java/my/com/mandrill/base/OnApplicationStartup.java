package my.com.mandrill.base;

import javax.persistence.EntityManager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class OnApplicationStartup {

	private static final Logger log = LoggerFactory.getLogger(OnApplicationStartup.class);

	@Autowired
	private EntityManager em;


	@EventListener(ApplicationReadyEvent.class)
	@Transactional
	public void resetJobHistoryStatus() {
		// Reset IN PROGRESS status in JOB HISTORY to FAILED
		try {
			int updateCount = em.createNativeQuery(
					"update JOB_HISTORY set status='FAILED', last_modified_by='system', last_modified_date=current_timestamp where status = 'IN PROGRESS'")
					.executeUpdate();
			log.debug("Reset {} JOB HISTORY records.", updateCount);

		} catch (Exception e) {
			log.warn("Failed to reset IN PROGRESS status in JOB HISTORY to FAILED.", e);
		}
	}
}
