package no.javazone.submit.services;

import no.javazone.submit.api.representations.EmailAddress;
import no.javazone.submit.api.representations.Submission;
import no.javazone.submit.api.representations.Token;
import no.javazone.submit.config.EmailConfiguration;
import no.javazone.submit.util.AuditLogger;
import org.apache.commons.mail.DefaultAuthenticator;
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Objects;

import static java.util.stream.Collectors.joining;
import static no.javazone.submit.util.AuditLogger.Event.SENT_EMAIL;

@Service
public class EmailService {

    private final Logger LOG = LoggerFactory.getLogger(this.getClass());

    private final EmailConfiguration emailConfiguration;
    private final AuthenticationService authenticationService;

    @Autowired
    public EmailService(EmailConfiguration emailConfiguration, AuthenticationService authenticationService) {
        this.emailConfiguration = emailConfiguration;
        this.authenticationService = authenticationService;
    }

    public void sendTokenToUser(EmailAddress emailAddress, Token token) {
        send(emailAddress, emailConfiguration.subjectPrefix + "CapraCon submission login", generateTokenEmail(token));
    }

    public void notifySpeakerAboutStatusChangeToInReview(Submission submission) {
        submission.speakers.stream()
                .map(s -> s.email)
                .map(EmailAddress::new)
                .filter(Objects::nonNull)
                .forEach(emailAddress -> {
                    Token token = authenticationService.createTokenForEmail(emailAddress);
                    send(emailAddress, emailConfiguration.subjectPrefix + "CapraCon submission marked for review: " + submission.title, generateReviewEmail(submission, token));
                });
    }

    private void send(EmailAddress address, String subject, String emailBody) {
        if (emailConfiguration.isLocalProfile()) {
            return;
        }
        try {
            Email email = new SimpleEmail();
            email.setHostName("smtp.googlemail.com");
            email.setSmtpPort(465);
            email.setAuthenticator(new DefaultAuthenticator(emailConfiguration.smtpUser, emailConfiguration.smtpPass));
            email.setSSLOnConnect(true);
            email.setFrom("program@java.no", "CapraCon Program Committee");
            email.setSubject(subject);
            email.setMsg(emailBody);
            email.addTo(address.toString());
            email.send();
            AuditLogger.log(SENT_EMAIL, "emailaddress " + address);
        } catch (EmailException e) {
            LOG.warn("Couldn't send email to " + address, e);
        }
    }

    private String generateTokenEmail(Token token) {
        StringBuilder b = new StringBuilder();
        b.append("Ready to submit a talk to JavaZone, or editing your talk?\n\n");
        b.append("Ready to submit a talk to CapraCon, or editing your talk?\n\n");
        b.append("Use this link to log your browser in to our submitting system:\n");
        b.append(emailConfiguration.tokenLinkPrefix).append("/").append(token).append("\n\n");
        b.append("Clicking this link will authenticate your browser and keep you logged in. Using a public computer? Use the 'forget me' button on the logged in page.").append("\n\n");
        b.append("Don't know why you received this email? Someone probably just misspelled their email address. Don't worry, they can't do anything on your behalf without this link").append("\n\n");
        b.append("Best regards,").append("\n").append("The JavaZone Program Committee");
        b.append("Best regards,").append("\n").append("The CapraCon Program Committee");
        return b.toString();
    }

    private String generateReviewEmail(Submission submission, Token token) {
        String speakerNames = submission.speakers.stream()
                .map(s -> s.name)
                .filter(Objects::nonNull)
                .filter((s) -> !s.isEmpty())
                .collect(joining(" & "));

        StringBuilder b = new StringBuilder();
        b.append("Dear " + speakerNames + "\n\n");
        b.append("Thank your for submitting your talk '" + submission.title + "' to CapraCon :)\n\n");
        b.append("You just marked your talk as ready for review, meaning that the program committee will have a look at it at their earliest convenience. This year, we are trying to give speakers who send their talks in early some feedback. In case the program committee has any feedback for you, they will send it to you by email.\n\n");
        b.append("Feel free to edit your talk further at any time. Just use the same browser as before - the submission system will keep you logged in. Alternatively, you can use this link to log any browser into our submission system to keep working on your talk:\n");
        b.append(emailConfiguration.tokenLinkPrefix).append("/").append(token).append("\n\n");
        b.append("Best regards,").append("\n").append("The CapraCon Program Committee");
        return b.toString();
    }
}
