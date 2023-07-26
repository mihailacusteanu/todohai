defmodule Todohai.Repo.Migrations.AddDeletedAt do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :deleted_at, :naive_datetime
    end
  end
end
