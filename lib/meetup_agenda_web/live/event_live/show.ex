defmodule MeetupAgendaWeb.EventLive.Show do
  use Surface.LiveComponent

  alias Surface.Components.LivePatch
  alias MeetupAgendaWeb.Router.Helpers, as: Routes

  prop event, :map
end
