package my.com.mandrill.base.config.audit;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

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
import my.com.mandrill.base.domain.AppResource;
import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.PersistentAuditEvent;
import my.com.mandrill.base.domain.RoleExtra;
import my.com.mandrill.base.domain.UserExtra;
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
	protected static final int EVENT_DATA_COLUMN_MAX_LENGTH = 2500;

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
				
				AuditEvent event = null;
				
				if (AuditActionType.RESET_PASSWORD_SUCCESS == type) {
					event = new AuditEvent(name, type.toString(), dataMap);
				} else {
					event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
				}
				
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
		ObjectDifferBuilder builder = ObjectDifferBuilder.startBuilding();
		builder.inclusion().exclude().propertyName("id");
		builder.inclusion().exclude().propertyName("createdBy");
		builder.inclusion().exclude().propertyName("createdDate");
		builder.inclusion().exclude().propertyName("lastModifiedBy");
		builder.inclusion().exclude().propertyName("lastModifiedDate");
		builder.inclusion().exclude().propertyName("roles");
		builder.inclusion().exclude().propertyName("permissions");
		builder.inclusion().exclude().propertyName("branches");
		builder.inclusion().exclude().propertyName("authorities");
		builder.inclusion().exclude().type(Instant.class);
		
		//DiffNode diff = ObjectDifferBuilder.buildDefault().compare(before, after);
		DiffNode diff = builder.build().compare(before, after);
		if (SecurityUtils.getCurrentUserLogin().isPresent()) {
			try {
				Map<String, Object> dataMap = new HashMap<String, Object>();
				List<ChangedItemDTO> changes = new ArrayList<>();

				if (diff.hasChanges()) {					
					diff.visit(new DiffNode.Visitor() {
						public void node(DiffNode node, Visit visit) {
							if (!node.hasChildren()) {
								try {
									final Object oldValue = node.canonicalGet(before);
									final Object newValue = node.canonicalGet(after);

									if (!skipLogging(node.getParentNode().getPropertyName())) {
										ChangedItemDTO dto = new ChangedItemDTO(node.getPropertyName(),
												(oldValue == null ? "" : oldValue.toString()),
												(newValue == null ? "" : newValue.toString()));
										changes.add(dto);
									}
								} catch (Exception e) {
									log.warn("Failed to audit field:{}", node.getPropertyName());
								}
								
							}
						}
					});	
				}
				changes.addAll(addListChange(before, after));
				if (changes.size() > 0) {
					dataMap.put("details", new ObjectMapper().writeValueAsString(changes));
				}
				AuditEvent event = new AuditEvent(SecurityUtils.getCurrentUserLogin().get(), type.toString(), dataMap);
				writeToAudit(event, reqService.getClientIp(req));
			} catch (Exception e) {
				log.warn("Failed to write Action Audit", e);
			}
		}
	}

	private List<ChangedItemDTO> addListChange(Object before, Object after) {
		List<ChangedItemDTO> changes = new ArrayList<ChangedItemDTO>();
		if (UserExtra.class == before.getClass()) {
			UserExtra beforeUser = (UserExtra) before;
			UserExtra afterUser = (UserExtra) after;

			String beforeBranch = beforeUser.getBranches().stream().sorted().map(Branch::getAbr_name)
					.collect(Collectors.joining(","));
			String afterBranch = afterUser.getBranches().stream().sorted().map(Branch::getAbr_name)
					.collect(Collectors.joining(","));
			if (!beforeBranch.contentEquals(afterBranch)) {
				ChangedItemDTO dto = new ChangedItemDTO("branch", beforeBranch, afterBranch);
				changes.add(dto);
			}

			String beforeRole = beforeUser.getRoles().stream().sorted().map(RoleExtra::getName)
					.collect(Collectors.joining(","));
			String afterRole = afterUser.getRoles().stream().sorted().map(RoleExtra::getName)
					.collect(Collectors.joining(","));
			if (!beforeRole.contentEquals(afterRole)) {
				ChangedItemDTO dto = new ChangedItemDTO("role", beforeRole, afterRole);
				changes.add(dto);
			}

		}
		if (RoleExtra.class == before.getClass()) {
			RoleExtra beforeRole = (RoleExtra) before;
			RoleExtra afterRole = (RoleExtra) after;

			String beforePermission = beforeRole.getPermissions().stream().sorted().map(AppResource::getName)
					.collect(Collectors.joining(","));
			String afterPermission = afterRole.getPermissions().stream().sorted().map(AppResource::getName)
					.collect(Collectors.joining(","));
			if (!beforePermission.contentEquals(afterPermission)) {
				ChangedItemDTO dto = new ChangedItemDTO("permission", beforePermission, afterPermission);
				changes.add(dto);
			}
		}

		return changes;
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
					sb.append(e.getMessage().replace(";", " "));
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
		log.debug("skiplogging check:{}", fieldName);
		return "createdDate".equals(fieldName) || "createdBy".equals(fieldName) || "lastModifiedBy".equals(fieldName)
				|| "lastMofiedDate".equals(fieldName) || "id".equals(fieldName) || "roles".equals(fieldName)
				|| "branches".equals(fieldName) || "permissions".equals(fieldName);

//		return "epochSecond".equals(fieldName) || "nano".equals(fieldName) || "createdDate".equals(fieldName)
//				|| "createdBy".equals(fieldName) || "lastModifiedBy".equals(fieldName)
//				|| "lastMofiedDate".equals(fieldName) || "id".equals(fieldName) || "dayOfMonth".equals(fieldName)
//				|| "dayOfWeek".equals(fieldName) || "dayOfYear".equals(fieldName) || "minute".equals(fieldName);
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

	public static void main(String[] args) {
		Branch branch = new Branch();
		branch.setAbr_code("001");
		branch.setAbr_name("Branch 001");
		Set<Branch> branchMap = new HashSet<>();
		branchMap.add(branch);

		RoleExtra role1 = new RoleExtra();
		role1.setId(1L);
		role1.setName("Role A");

		RoleExtra role2 = new RoleExtra();
		role2.setId(2L);
		role2.setName("Role B");

		Set<RoleExtra> roleMap1 = new HashSet<>();
		roleMap1.add(role1);
		roleMap1.add(role2);

		Set<RoleExtra> roleMap2 = new HashSet<>();
		roleMap2.add(role2);
		roleMap2.add(role1);

		UserExtra a = new UserExtra();
		a.setName("User A");
		a.setDesignation("x");
		a.setRoles(roleMap1);

		UserExtra b = new UserExtra();
		b.setName("User A");
		b.setDesignation("0");
		b.setBranches(branchMap);
		// b.setRoles(roleMap2);

		String beforeRole = a.getRoles().stream().sorted().map(RoleExtra::getName).collect(Collectors.joining(","));
		String afterRole = b.getRoles().stream().sorted().map(RoleExtra::getName).collect(Collectors.joining(","));

		if (!beforeRole.contentEquals(afterRole)) {
			System.out.println("before=" + beforeRole + ", after=" + afterRole);
		} else {
			System.out.println("content is same");
		}

	}
}
