defmodule Todohai.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :is_done, :boolean, default: false, null: false
      add :parent_id, references(:items, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:parent_id])
  end
end
