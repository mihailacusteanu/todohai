defmodule Todohai.Schema.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :is_done, :boolean, default: false
    field :name, :string
    field :parent_id, :id

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :is_done])
    |> validate_required([:name, :is_done])
  end
end
