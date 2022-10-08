defmodule Todohai.Repo.Migrations.AddUserToItemsTable do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :user_id, references(:users)
    end
  end
end
