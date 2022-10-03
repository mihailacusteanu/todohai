defmodule Todohai.Repo do
  use Ecto.Repo,
    otp_app: :todohai,
    adapter: Ecto.Adapters.Postgres
end
