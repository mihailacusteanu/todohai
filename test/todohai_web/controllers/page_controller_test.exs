defmodule TodohaiWeb.PageControllerTest do
  use TodohaiWeb.ConnCase

  setup :register_and_log_in_user

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "My account"
  end
end
