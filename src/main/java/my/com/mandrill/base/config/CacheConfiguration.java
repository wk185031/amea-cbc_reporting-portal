package my.com.mandrill.base.config;

import io.github.jhipster.config.JHipsterProperties;
import org.ehcache.config.builders.CacheConfigurationBuilder;
import org.ehcache.config.builders.ResourcePoolsBuilder;
import org.ehcache.expiry.Duration;
import org.ehcache.expiry.Expirations;
import org.ehcache.jsr107.Eh107Configuration;

import java.util.concurrent.TimeUnit;

import org.springframework.boot.autoconfigure.AutoConfigureAfter;
import org.springframework.boot.autoconfigure.AutoConfigureBefore;
import org.springframework.boot.autoconfigure.cache.JCacheManagerCustomizer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.*;

@Configuration
@EnableCaching
@AutoConfigureAfter(value = { MetricsConfiguration.class })
@AutoConfigureBefore(value = { WebConfigurer.class, DatabaseConfiguration.class })
public class CacheConfiguration {

    private final javax.cache.configuration.Configuration<Object, Object> jcacheConfiguration;

    public CacheConfiguration(JHipsterProperties jHipsterProperties) {
        JHipsterProperties.Cache.Ehcache ehcache =
            jHipsterProperties.getCache().getEhcache();

        jcacheConfiguration = Eh107Configuration.fromEhcacheCacheConfiguration(
            CacheConfigurationBuilder.newCacheConfigurationBuilder(Object.class, Object.class,
                ResourcePoolsBuilder.heap(ehcache.getMaxEntries()))
                .withExpiry(Expirations.timeToLiveExpiration(Duration.of(ehcache.getTimeToLiveSeconds(), TimeUnit.SECONDS)))
                .build());
    }

    @Bean
    public JCacheManagerCustomizer cacheManagerCustomizer() {
        return cm -> {
            cm.createCache(my.com.mandrill.base.repository.UserRepository.USERS_BY_LOGIN_CACHE, jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.repository.UserRepository.USERS_BY_EMAIL_CACHE, jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.User.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.Authority.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.User.class.getName() + ".authorities", jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.UserExtra.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.UserExtra.class.getName() + ".roles", jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.UserExtra.class.getName() + ".institutions", jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.RoleExtra.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.RoleExtra.class.getName() + ".permissions", jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.AppResource.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.SystemConfiguration.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.Institution.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.AttachmentGroup.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.Attachment.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.ReportCategory.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.ReportDefinition.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.ReportGeneration.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.SecurityParameters.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.SecureKey.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.LocalWebService.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.EncryptionKey.class.getName(), jcacheConfiguration);
            // jhipster-needle-ehcache-add-entry
            cm.createCache(my.com.mandrill.base.domain.EntityAuditEvent.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.Job.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.JobHistory.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.TaskGroup.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.Task.class.getName(), jcacheConfiguration);
            cm.createCache(my.com.mandrill.base.domain.TxnLogCustom.class.getName(), jcacheConfiguration);
        };
    }
}
