defmodule Todohai.Repo.Migrations.AddNoOfChildrenToItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :no_of_children, :integer, default: 0
      add :no_of_done_children, :integer, default: 0
      add :no_of_not_done_children, :integer, default: 0
    end
  end
end
