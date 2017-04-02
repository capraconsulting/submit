package no.javazone.submit.integrations.sleepingpill.model.create;

import no.javazone.submit.integrations.sleepingpill.model.common.SessionData;
import no.javazone.submit.integrations.sleepingpill.model.common.SessionStatus;
import no.javazone.submit.api.representations.EmailAddress;

import java.util.List;

import static java.util.Collections.singletonList;

public class NewSession {

    public List<NewSpeaker> speakers;
    public SessionData data;
    public SessionStatus status;
    public String postedBy;

    @SuppressWarnings("unused")
    private NewSession() { }

    public NewSession(SessionStatus status, String postedBy, String title, String theAbstract, String intendedAudience,
                      String format, String language, String outline, String equipment, String length, String level, String suggestedKeywords,
                      String infoToProgramCommittee, List<NewSpeaker> speakers) {

        this.status = status;
        this.postedBy = postedBy;
        this.speakers = speakers;

        data = new SessionData();
        data.setTitle(title);
        data.setAbstract(theAbstract);
        data.setIntendedAudience(intendedAudience);
        data.setFormat(format);
        data.setLanguage(language);
        data.setOutline(outline);
        data.setEquipment(equipment);
        data.setLength(length);
        data.setLevel(level);
        data.setSuggestedKeywords(suggestedKeywords);
        data.setInfoToProgramCommittee(infoToProgramCommittee);
    }

    public static NewSession draft(EmailAddress postedBy) {
        return new NewSession(
                SessionStatus.DRAFT,
                postedBy.toString(),
                "New draft for your CapraCon talk",
                "",
                "",
                "presentation",
                "en",
                "",
                "",
                "60",
                "beginner",
                "",
                "",
                singletonList(NewSpeaker.draft(postedBy)));
    }
}
