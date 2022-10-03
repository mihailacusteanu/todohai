defmodule Todohai.Schema.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(name is_done)a
  @optional_fields ~w(parent_id)a

  schema "items" do
    field :is_done, :boolean, default: false
    field :name, :string
    belongs_to :parent, __MODULE__

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
