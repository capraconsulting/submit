package no.javazone.submit.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
@ConfigurationProperties(prefix = "email")
public class EmailConfiguration {
    private Environment environment;

    public String smtpUser;

    public String smtpPass;

    public String tokenLinkPrefix;

    public String subjectPrefix;

    public String smtpHost;

    public String senderEmail;

    public void setSenderEmail(String senderEmail) {
        this.senderEmail = senderEmail;
    }

    public void setSmtpHost(String smtpHost) {
        this.smtpHost = smtpHost;
    }

    public void setSmtpUser(String smtpUser) {
        this.smtpUser = smtpUser;
    }

    public void setSmtpPass(String smtpPass) {
        this.smtpPass = smtpPass;
    }

    public void setTokenLinkPrefix(String tokenLinkPrefix) {
        this.tokenLinkPrefix = tokenLinkPrefix;
    }

    public void setSubjectPrefix(String subjectPrefix) {
        this.subjectPrefix = subjectPrefix;
    }

    @Autowired
    public void setEnvironment(Environment environment) {
        this.environment = environment;
    }

    public boolean isLocalProfile() {
        return Arrays.stream(environment.getActiveProfiles()).anyMatch(p -> p.equals("local"));

    }
}
