package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.Instant;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

/**
 * LocalWebService, to store local web service details
 */
@ApiModel(description = "LocalWebService, to store local web service details")
@Entity
@Table(name = "local_web_service")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "local_web_service")
public class LocalWebService implements Serializable {
	private static final long serialVersionUID = 1L;

	@NotNull
	@Size(max = 250)
	@Column(name = "lws_service_name", length = 250, nullable = false)
	private String serviceName;

	@NotNull
	@Size(max = 50)
	@Column(name = "lws_ips_name", length = 50, nullable = false)
	private String ipsName;

	@NotNull
	@Size(max = 1)
	@Column(name = "lws_active_flag", length = 1, nullable = false)
	private String activeFlag;

	@Size(max = 255)
	@Column(name = "lws_client_service_class", length = 255, nullable = true)
	private String clientServiceClass;

	@Size(max = 255)
	@Column(name = "lws_server_service_impl_class", length = 255, nullable = true)
	private String serverServiceImplClass;

	@Size(max = 250)
	@Column(name = "lws_endpoint_url", length = 250, nullable = true)
	private String endpointUrl;

	@Size(max = 250)
	@Column(name = "lws_wsdl_url", length = 250, nullable = true)
	private String wsdlUrl;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Size(max = 19)
	@Column(name = "lws_key_store_seck_id", length = 19, nullable = true)
	private Long id;

	@Size(max = 19)
	@Column(name = "lws_trust_store_seck_id", length = 19, nullable = true)
	private Long trustStoreSeckId;

	@Size(max = 1000)
	@Column(name = "lws_queue_name", length = 1000, nullable = true)
	private String queueName;

	@LastModifiedDate
	@Column(name = "lws_last_update_ts", nullable = true)
	private Instant lastUpdateTs = Instant.now();

	public String getServiceName() {
		return serviceName;
	}

	public LocalWebService serviceName(String serviceName) {
		this.serviceName = serviceName;
		return this;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public String getIpsName() {
		return ipsName;
	}

	public LocalWebService ipsName(String ipsName) {
		this.ipsName = ipsName;
		return this;
	}

	public void setIpsName(String ipsName) {
		this.ipsName = ipsName;
	}

	public String getActiveFlag() {
		return activeFlag;
	}

	public LocalWebService activeFlag(String activeFlag) {
		this.activeFlag = activeFlag;
		return this;
	}

	public void setActiveFlag(String activeFlag) {
		this.activeFlag = activeFlag;
	}

	public String getClientServiceClass() {
		return clientServiceClass;
	}

	public LocalWebService clientServiceClass(String clientServiceClass) {
		this.clientServiceClass = clientServiceClass;
		return this;
	}

	public void setClientServiceClass(String clientServiceClass) {
		this.clientServiceClass = clientServiceClass;
	}

	public String getServerServiceImplClass() {
		return serverServiceImplClass;
	}

	public LocalWebService serverServiceImplClass(String serverServiceImplClass) {
		this.serverServiceImplClass = serverServiceImplClass;
		return this;
	}

	public void setServerServiceImplClass(String serverServiceImplClass) {
		this.serverServiceImplClass = serverServiceImplClass;
	}

	public String getEndpointUrl() {
		return endpointUrl;
	}

	public LocalWebService endpointUrl(String endpointUrl) {
		this.endpointUrl = endpointUrl;
		return this;
	}

	public void setEndpointUrl(String endpointUrl) {
		this.endpointUrl = endpointUrl;
	}

	public String getWsdlUrl() {
		return wsdlUrl;
	}

	public LocalWebService wsdlUrl(String wsdlUrl) {
		this.wsdlUrl = wsdlUrl;
		return this;
	}

	public void setWsdlUrl(String wsdlUrl) {
		this.wsdlUrl = wsdlUrl;
	}

	public Long getId() {
		return id;
	}

	public LocalWebService keyStoreSeckId(Long keyStoreSeckId) {
		this.id = keyStoreSeckId;
		return this;
	}

	public void setId(Long keyStoreSeckId) {
		this.id = keyStoreSeckId;
	}

	public Long getTrustStoreSeckId() {
		return trustStoreSeckId;
	}

	public LocalWebService trustStoreSeckId(Long trustStoreSeckId) {
		this.trustStoreSeckId = trustStoreSeckId;
		return this;
	}

	public void setTrustStoreSeckId(Long trustStoreSeckId) {
		this.trustStoreSeckId = trustStoreSeckId;
	}

	public String getQueueName() {
		return queueName;
	}

	public LocalWebService queueName(String queueName) {
		this.queueName = queueName;
		return this;
	}

	public void setQueueName(String queueName) {
		this.queueName = queueName;
	}

	public Instant getLastUpdateTs() {
		return lastUpdateTs;
	}

	public LocalWebService lastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
		return this;
	}

	public void setLastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
	}

	@Override
	public String toString() {
		return "LocalWebService [serviceName=" + serviceName + ", ipsName=" + ipsName + ", activeFlag=" + activeFlag
				+ ", clientServiceClass=" + clientServiceClass + ", serverServiceImplClass=" + serverServiceImplClass
				+ ", endpointUrl=" + endpointUrl + ", wsdlUrl=" + wsdlUrl + ", keyStoreSeckId=" + id
				+ ", trustStoreSeckId=" + trustStoreSeckId + ", queueName=" + queueName + ", lastUpdateTs="
				+ lastUpdateTs + "]";
	}
}
