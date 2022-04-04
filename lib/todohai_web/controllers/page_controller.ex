defmodule TodohaiWeb.PageController do
  use TodohaiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
