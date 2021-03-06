module View.Submission exposing (view)

import Model.Submission exposing (..)
import Messages exposing (..)
import Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style, type_, value, src, placeholder, href, name, checked, selected, id, for)
import Html.Events exposing (onInput, onClick, on)
import Nav.Nav exposing (toHash)
import Nav.Model
import Backend.Network exposing (RequestStatus(..))
import Time
import Date
import String
import Json.Decode exposing (succeed)


view : Model -> Html Msg
view model =
    case model.submission of
        Initial ->
            div [] []

        Loading ->
            viewLoading

        Complete submission ->
            viewSubmission submission model

        Error message ->
            viewError message


viewLoading : Html Msg
viewLoading =
    div [ class "wrapper" ]
        [ div [ class "logo-wrapper" ] [ img [ src "assets/neon-logo.svg", class "logo" ] [] ]
        , div [ class "edit-submission" ]
            [ div [ class "edit-submission loading" ] [ text "Loading ..." ] ]
        ]


viewSubmission : Submission -> Model -> Html Msg
viewSubmission submission model =
    div [ class "wrapper" ]
        [ viewFooter submission model
        , Html.map UpdateSubmission <| viewSubmissionDetails submission model
        ]


viewFooter : Submission -> Model -> Html Msg
viewFooter submission model =
    div [ class "sticky-footer" ]
        [ div [ class "sticky-footer-content" ]
            [ div []
                [ a [ href << toHash <| Nav.Model.Submissions ]
                    [ button [ class "button-back" ] [ text "Back to list" ] ]
                ]
            , div [ class <| "save-controls " ++ hideIfNotEditable submission.editable ]
                [ div [ class "autosave" ]
                    [ div []
                        [ label [ for "autosave" ] [ text "Autosave changes" ]
                        , div [ class "lastsaved" ] [ text <| viewLastSaved model.lastSaved ]
                        ]
                    , div [ class "autosave-checkbox" ]
                        [ input [ id "autosave", type_ "checkbox", onClick ToggleAutosaveSubmission, checked model.autosave ] []
                        ]
                    ]
                , div []
                    [ button [ class "button-save", onClick (SaveSubmission 0) ] [ text "Save now" ] ]
                ]
            ]
        ]


viewSubmissionDetails : Submission -> Model -> Html SubmissionField
viewSubmissionDetails submission model =
    div []
        [ div [ class "logo-wrapper" ] [ img [ src "assets/neon-logo.svg", class "logo" ] [] ]
        , div [ class <| "edit-intro " ++ hideIfNotEditable submission.editable ]
            [ h1 [] [ text "Ready? Let's make your talk a reality!" ]
            , p [ class "ingress" ] [ text "CapraCon takes place in Oslo, Norway, on October 13th-14th 2017. Do YOU want to be one of the great speakers at our conference? Fantastic! That's what this thing is for! Let's get you started!" ]
            ]
        , div [ class "edit-submission" ]
            [ div [ class <| "cant-edit-message " ++ hideIfEditable submission.editable ] [ text "You can't edit this talk. Only talks from the current year is editable." ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Title" ]
                , p [ class "input-description" ] [ text "Select an expressive and snappy title that captures the content of your talk without being too long. Remember that the title must be attractive and should make people curious." ]
                , input [ type_ "text", value submission.title, onInput Title, placeholder "A short and snappy title catching people's interest" ] []
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Language" ]
                , p [ class "input-description" ] [ text "Which language will you be holding the talk in? It is permitted to use English in your slides, even though you may be talking in Norwegian, but you should write the rest of the abstract in the language you will speak in. We generally recommend that you hold the talk in the language you are most comfortable with." ]
                , radio "Norwegian" "language" "no" (Language "no") <| submission.language == "no"
                , radio "English" "language" "en" (Language "en") <| submission.language == "en"
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Description" ]
                , p [ class "input-description" ] [ text "Give a concise description of the content and goals of your talk. Try not to exceed 300 words, as shorter and more to-the-point descriptions are more likely to be read by the participants." ]
                , textarea [ value submission.abstract, onInput Abstract, placeholder "Try to sell your presentation as best as possible to the audience. \n\nShort and to the point is often a good starting point!" ] []
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Expected audience and code level" ]
                , p [ class "input-description" ] [ text "Who should attend this session?  How will the participants benefit from attending?  Please indicate how code will factor into your presentation (for example \"no code\", \"code in slides\" or \"live coding\")." ]
                , textarea [ class "small-textarea", value submission.intendedAudience, onInput IntendedAudience, placeholder "Who do you hope will be sitting in the audience for your talk?" ] []
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Presentation format" ]
                , p [ class "input-description" ] [ text "In which format are you presenting your talk?" ]
                , radio "Presentation" "format" "presentation" (Format "presentation") <| submission.format == "presentation"
                , radio "Lightning Talk" "format" "lightning-talk" (Format "lightning-talk") <| submission.format == "lightning-talk"
                , radio "Workshop" "format" "workshop" (Format "workshop") <| submission.format == "workshop"
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Presentation length" ]
                , p [ class "input-description" ] [ text <| formatText submission.format ]
                , viewLength submission
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Experience level" ]
                , p [ class "input-description" ] [ text "Who is your talk pitched at?  Beginners, Experts or perhaps those in between?" ]
                , radio "Beginner" "experience" "beginner" (Level "beginner") <| submission.level == "beginner"
                , radio "Intermediate" "experience" "intermediate" (Level "intermediate") <| submission.level == "intermediate"
                , radio "Advanced" "experience" "advanced" (Level "advanced") <| submission.level == "advanced"
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Suggested keywords" ]
                , p [ class "input-description" ] [ text "Suggest up to five keywords that describe your talk. These will be used by the program committee to group the talks into categories. We reserve the right to edit these suggestions to make them fit into this years selected categories." ]
                , input [ type_ "text", value submission.suggestedKeywords, onInput SuggestedKeywords, placeholder "Keyword 1, Keyword 2, ..." ] []
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Outline (not public)" ]
                , p [ class "input-description" ] [ text "The information will be used by the Program Committee to review the details of your talk. The outline should be a rough agenda for the talk, with a short description for each section, and with a rough estimate of the time spent on each. Omitting this section will reduce the chances of your submission being accepted." ]
                , textarea [ value submission.outline, onInput Outline, placeholder "The more detailed you are, the bigger your changes of being accepted.\n\nA good format to follow:\n- Part 1: Introduction (xx minutes)\n   - detail...\n   - detail...\n- Part 2: ... (yy minutes)\n   - detail...\n- (more)" ] []
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Equipment (not public)" ]
                , p [ class "input-description" ] [ text "Please specify any additional special equipment you may need. Note that all get access to WiFi and a projector." ]
                , textarea [ class "small-textarea", value submission.equipment, onInput Equipment, placeholder "Let us know if your talk or workshop depends on us providing you with anything to ensure it's success." ] []
                ]
            , div [ class "input-section" ]
                [ h2 [] [ text "Additional information for the Program Committee (not public)" ]
                , p [ class "input-description" ] [ text "Please include any information relevant to the Program Committee. Here you can write a few words about your motivation for speaking at CapraCon, and optionally include links to videos and slides from previous speaker engagements, or other links that tell us about you (e.g. your GitHub profile)." ]
                , textarea [ class "small-textarea", value submission.infoToProgramCommittee, onInput InfoToProgramCommittee, placeholder "Let us know who you are, why you are passionate about this subject, and why YOU are the best person to hold this talk.\n\nNorwegian rules do not apply: it's allowed to brag a bit ;)" ] []
                ]
            , div [ class "input-section" ]
                [ div [ class "flex-header" ]
                    [ h2 [ class "flex-header-element" ] [ text "Who are you?" ]
                    , div [ class "flex-header-element" ]
                        [ if List.length submission.speakers > 1 then
                            div [] []
                          else
                            button [ onClick AddSpeaker, class "button-new" ] [ text "Add second speaker" ]
                        ]
                    ]
                , p [ class "input-description" ] [ text "Please give us a little bit of information about yourself. You can also add any additional speakers here. All of you will be shown in the program." ]
                , ul [ class "speakers" ] <|
                    List.map (viewSpeaker submission <| List.length submission.speakers) submission.speakers
                ]
            , div [ class <| "input-section " ++ hideIfNotEditable submission.editable ]
                [ h2 [] [ text "How finished are you with your abstract?" ]
                , p [ class "input-description" ] [ text "Keep it as a draft until you have filled in everything. If you set it to ready for review before March 27th, we'll try to give you some personal feedback. Don't worry, you can still make changes after marking it as ready for review." ]
                , p [ class "input-description input-description-strong" ] [ text "Make sure you mark it as ready by April 24th at the latest to have your talk considered for CapraCon 2017! Mark your calendar! ;)" ]
                , radio "Not ready: Keep it as my personal draft" "status" "DRAFT" (Status "DRAFT") <| submission.status == "DRAFT"
                , radio "Ready: Let the program committee look at it" "status" "SUBMITTED" (Status "SUBMITTED") <| submission.status == "SUBMITTED"
                ]
            , div [ class "sticky-footer-filler" ] []
            ]
        ]


viewLength : Submission -> Html SubmissionField
viewLength s =
    case s.format of
        "presentation" ->
            select [ onInput Length ]
                [ option [ value "45", selected <| s.length == "45" ] [ text "45 minutes" ]
                , option [ value "60", selected <| s.length == "60" ] [ text "60 minutes" ]
                ]

        "lightning-talk" ->
            select [ onInput Length ]
                [ option [ value "10", selected <| s.length == "10" ] [ text "10 minutes" ]
                , option [ value "20", selected <| s.length == "20" ] [ text "20 minutes" ]
                ]

        _ ->
            select [ onInput Length ]
                [ option [ value "120", selected <| s.length == "120" ] [ text "2 hours" ]
                , option [ value "240", selected <| s.length == "240" ] [ text "4 hours" ]
                , option [ value "480", selected <| s.length == "480" ] [ text "8 hours" ]
                ]


viewSpeaker : Submission -> Int -> ( Int, Speaker ) -> Html SubmissionField
viewSpeaker submission n ( i, speaker ) =
    let
        removeButton =
            if n == 1 then
                div [] []
            else if not speaker.deletable then
                div [] []
            else
                div [ class "flex-header-element" ]
                    [ button [ onClick (RemoveSpeaker i), class "button-delete" ] [ text "Remove speaker" ]
                    ]
    in
        li [ class "speaker" ]
            [ div [ class "flex-header" ]
                [ h2 [ class "flex-header-element" ] [ text ("Speaker " ++ toString (i + 1)) ]
                , removeButton
                ]
            , div [ class "speaker-input-section" ]
                [ h3 [] [ text "Speakers name" ]
                , input [ type_ "text", value speaker.name, placeholder "Speaker name", onInput <| SpeakerName i ] []
                ]
            , div [ class "speaker-input-section" ]
                [ h3 [] [ text "Speakers email (not public)" ]
                , input [ type_ "text", value speaker.email, placeholder "Speaker email", onInput <| SpeakerEmail i ] []
                ]
            , div [ class "speaker-input-section" ]
                [ h3 [] [ text "Short description of the speaker (try not to exceed 150 words)" ]
                , textarea [ value speaker.bio, placeholder "Tell the audience who this speaker is, and why she/he is the perfect person to hold this talk.", onInput <| SpeakerBio i ] []
                ]
            , div [ class "speaker-input-section" ]
                [ h3 [] [ text "Your Twitter handle (optional)" ]
                , input [ type_ "text", value speaker.twitter, placeholder "@YourTwitterName", onInput <| SpeakerTwitter i ] []
                ]
            , div [ class "speaker-input-section" ]
                [ h3 [] [ text "Your norwegian ZIP Code (optional)" ]
                , input [ type_ "text", value speaker.zipCode, onInput <| SpeakerZipCode i, placeholder "Will let us contact you about future speaking opportunities in local javaBin user groups :)" ] []
                ]
            , div [ class "speaker-input-section" ]
                [ h3 [] [ text "Speakers image" ]
                , p [ class "input-description" ]
                    [ text "Please upload a good image of yourself."
                    , b [] [ text " Max 500 KB. " ]
                    , text "If you don't upload a picture, we'll try to use the gravatar image connected to your email address."
                    ]
                , input [ class "speaker-image-input", type_ "file", id <| "SpeakerImage" ++ toString i, on "change" (succeed <| FileSelected speaker i <| "SpeakerImage" ++ toString i) ] []
                , speakerImage speaker
                ]
            ]


viewError : String -> Html Msg
viewError message =
    div [] [ text message ]


hideIfEditable : Bool -> String
hideIfEditable editable =
    if editable then
        "hide"
    else
        ""


hideIfNotEditable : Bool -> String
hideIfNotEditable editable =
    if not editable then
        "hide"
    else
        ""


radio : String -> String -> String -> msg -> Bool -> Html msg
radio l group val msg selected =
    div [ class "radio-input" ]
        [ label []
            [ input [ type_ "radio", name group, value val, onClick msg, checked selected ] []
            , text l
            ]
        ]


formatText : String -> String
formatText format =
    case format of
        "presentation" ->
            "Please select the length of the presentation (in minutes). Presentations can have a length of 45 or 60 minutes. Including Q&A"

        "lightning-talk" ->
            "Please select the length of the presentation (in minutes). Lightning talks can be 10 or 20 minutes long. The time limit is strictly enforced"

        _ ->
            "Please select the length of the presentation (in minutes). Workshops last 2, 4 or 8 hours (120, 240 or 480 minutes)"


viewLastSaved : Maybe Time.Time -> String
viewLastSaved time =
    case time of
        Just t ->
            let
                date =
                    Date.fromTime t
            in
                "Last saved "
                    ++ (String.join ":"
                            << List.map (zeroPad << toString)
                        <|
                            [ Date.hour date, Date.minute date, Date.second date ]
                       )

        Nothing ->
            "Not edited yet"


zeroPad : String -> String
zeroPad n =
    if String.length n == 1 then
        "0" ++ n
    else
        n


speakerImage : Speaker -> Html SubmissionField
speakerImage speaker =
    if speaker.hasPicture then
        div [ style <| [ ( "background-image", "url(" ++ speaker.pictureUrl ++ ")" ) ], class "speaker-image" ] []
    else
        img [ src "assets/robot_padded_arm.png", class "speaker-image" ] []
