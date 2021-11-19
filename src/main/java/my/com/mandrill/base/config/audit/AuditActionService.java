package my.com.mandrill.base.config.audit;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.actuate.audit.AuditEvent;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import my.com.mandrill.base.repository.CustomAuditEventRepository;
import my.com.mandrill.base.repository.PersistenceAuditEventRepository;
import my.com.mandrill.base.security.SecurityUtils;

@Service
@Transactional
public class AuditActionService {

	private final Logger log = LoggerFactory.getLogger(AuditActionService.class);
	
	private final PersistenceAuditEventRepository persistenceAuditEventRepository;
	
	private final AuditEventConverter auditEventConverter;

	private final CustomAuditEventRepository customAuditEventRepository;

	public AuditActionService(PersistenceAuditEventRepository persistenceAuditEventRepository, AuditEventConverter auditEventConverter) {
		this.persistenceAuditEventRepository = persistenceAuditEventRepository;
		this.auditEventConverter = auditEventConverter;
		customAuditEventRepository = new CustomAuditEventRepository(persistenceAuditEventRepository, auditEventConverter);
	}

	public void addSuccessEvent(AuditActionType type, String name) {
		try {
			Map<String, Object> dataMap = new HashMap<String, Object>();
			if (name != null) {
				dataMap.put("name", name);
			}

			AuditEvent event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
			customAuditEventRepository.add(event);
		} catch (Exception e) {
			log.warn("Failed to write Action Audit", e);
		}

	}

	public void addFailedEvent(AuditActionType type, String name, Exception e) {
		try {
			Map<String, Object> dataMap = new HashMap<String, Object>();
			dataMap.put("message", e.getMessage());
			if (name != null) {
				dataMap.put("name", name);
			}

			AuditEvent event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
			customAuditEventRepository.add(event);
		} catch (Exception ex) {
			log.warn("Failed to write Action Audit", ex);
		}

	}
}
