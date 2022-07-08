defmodule MeetupAgendaWeb.PageController do
  use MeetupAgendaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
