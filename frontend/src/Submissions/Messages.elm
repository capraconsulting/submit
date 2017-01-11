module Submissions.Messages exposing (Msg(..))

import Submissions.Model exposing (..)
import Http


type Msg
    = Message
    | Get (Result Http.Error Submissions)
    | CreateTalk
    | Created (Result Http.Error String)
    | Logout
    | LoggedOut (Result Http.Error String)
    | TokenRemoved ()
