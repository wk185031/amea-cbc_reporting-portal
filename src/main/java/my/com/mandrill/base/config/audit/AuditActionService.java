package my.com.mandrill.base.config.audit;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.actuate.audit.AuditEvent;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import de.danielbechler.diff.ObjectDifferBuilder;
import de.danielbechler.diff.node.DiffNode;
import de.danielbechler.diff.node.Visit;
import my.com.mandrill.base.config.Constants;
import my.com.mandrill.base.domain.PersistentAuditEvent;
import my.com.mandrill.base.repository.CustomAuditEventRepository;
import my.com.mandrill.base.repository.PersistenceAuditEventRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.RequestService;
import my.com.mandrill.base.service.dto.ChangedItemDTO;

@Service
public class AuditActionService {

	private final Logger log = LoggerFactory.getLogger(AuditActionService.class);

	private final PersistenceAuditEventRepository persistenceAuditEventRepository;

	private final AuditEventConverter auditEventConverter;

	private final CustomAuditEventRepository customAuditEventRepository;

	private final RequestService reqService;

	private static final String AUTHORIZATION_FAILURE = "AUTHORIZATION_FAILURE";
	protected static final int EVENT_DATA_COLUMN_MAX_LENGTH = 255;

	public AuditActionService(PersistenceAuditEventRepository persistenceAuditEventRepository,
			AuditEventConverter auditEventConverter, RequestService reqService) {
		this.persistenceAuditEventRepository = persistenceAuditEventRepository;
		this.auditEventConverter = auditEventConverter;
		this.reqService = reqService;
		customAuditEventRepository = new CustomAuditEventRepository(persistenceAuditEventRepository,
				auditEventConverter);
	}

	public void addSuccessEvent(AuditActionType type, String name) {
		addSuccessEvent(type, name, null);
	}

	public void addSuccessEvent(AuditActionType type, String name, HttpServletRequest req) {
		try {
			if (SecurityUtils.getCurrentUserLogin().isPresent()) {
				Map<String, Object> dataMap = new HashMap<String, Object>();
				AuditEvent event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
				if (name != null) {
					dataMap.put("details", "ID: " + name);
				}

				if (req == null) {
					writeToAudit(event);
				} else {
					writeToAudit(event, reqService.getClientIp(req));
				}
			}

		} catch (Exception e) {
			log.warn("Failed to write Action Audit", e);
		}
	}

	public void addSuccessEvent(AuditActionType type, Object before, Object after, HttpServletRequest req) {
		DiffNode diff = ObjectDifferBuilder.buildDefault().compare(before, after);
		if (SecurityUtils.getCurrentUserLogin().isPresent()) {
			try {
				Map<String, Object> dataMap = new HashMap<String, Object>();

				if (diff.hasChanges()) {
					List<ChangedItemDTO> changes = new ArrayList<>();
					diff.visit(new DiffNode.Visitor() {
						public void node(DiffNode node, Visit visit) {
							if (!node.hasChildren()) {
								final Object oldValue = node.canonicalGet(before);
								final Object newValue = node.canonicalGet(after);

								if (!skipLogging(node.getPropertyName())) {
									ChangedItemDTO dto = new ChangedItemDTO(node.getPropertyName(),
											oldValue == null ? "" : oldValue.toString(),
											newValue == null ? "" : newValue.toString());
									changes.add(dto);
								}
							}
						}
					});
					dataMap.put("details", new ObjectMapper().writeValueAsString(changes));
				}

				AuditEvent event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
				writeToAudit(event, reqService.getClientIp(req));
			} catch (Exception e) {
				log.warn("Failed to write Action Audit", e);
			}
		}
	}

	public void addFailedEvent(AuditActionType type, String name, Exception e, HttpServletRequest req) {
		try {
			if (SecurityUtils.getCurrentUserLogin().isPresent()) {
				StringBuilder sb = new StringBuilder();
				sb.append("FAILED: ");

				if (name != null) {
					sb.append("[").append(name).append("] ");
				}

				if (e != null) {
					sb.append(e.getMessage());
				}

				Map<String, Object> dataMap = new HashMap<String, Object>();
				dataMap.put("details", new ObjectMapper().writeValueAsString(sb.toString()));

				AuditEvent event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
				writeToAudit(event, reqService.getClientIp(req));
			}
		} catch (Exception ex) {
			log.warn("Failed to write Action Audit", ex);
		}

	}

	public boolean skipLogging(String fieldName) {
		return "epochSecond".equals(fieldName) || "nano".equals(fieldName) || "createdDate".equals(fieldName)
				|| "createdBy".equals(fieldName) || "lastModifiedBy".equals(fieldName)
				|| "lastMofiedDate".equals(fieldName) || "id".equals(fieldName);
	}

	public void writeToAudit(AuditEvent event) {
		writeToAudit(event, null);
	}

	@Transactional(propagation = Propagation.REQUIRES_NEW)
	public void writeToAudit(AuditEvent event, String ip) {
		if (!AUTHORIZATION_FAILURE.equals(event.getType()) && !Constants.ANONYMOUS_USER.equals(event.getPrincipal())) {

			PersistentAuditEvent persistentAuditEvent = new PersistentAuditEvent();
			persistentAuditEvent.setPrincipal(event.getPrincipal());
			persistentAuditEvent.setAuditEventType(event.getType());
			persistentAuditEvent.setAuditEventDate(event.getTimestamp().toInstant());
			persistentAuditEvent.setSourceIp(ip);
			Map<String, String> eventData = auditEventConverter.convertDataToStrings(event.getData());
			persistentAuditEvent.setData(truncate(eventData));
			persistenceAuditEventRepository.save(persistentAuditEvent);
		}
	}

	private Map<String, String> truncate(Map<String, String> data) {
		Map<String, String> results = new HashMap<>();

		if (data != null) {
			for (Map.Entry<String, String> entry : data.entrySet()) {
				String value = entry.getValue();
				if (value != null) {
					int length = value.length();
					if (length > EVENT_DATA_COLUMN_MAX_LENGTH) {
						value = value.substring(0, EVENT_DATA_COLUMN_MAX_LENGTH);
						log.warn(
								"Event data for {} too long ({}) has been truncated to {}. Consider increasing column width.",
								entry.getKey(), length, EVENT_DATA_COLUMN_MAX_LENGTH);
					}
				}
				results.put(entry.getKey(), value);
			}
		}
		return results;
	}
}
