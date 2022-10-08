defmodule Todohai.Schema.Item do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type id() :: integer()

  @required_fields ~w(name is_done no_of_children no_of_done_children user_id)a
  @optional_fields ~w(parent_id)a

  schema "items" do
    field :is_done, :boolean, default: false
    field :name, :string
    field :no_of_children, :integer, default: 0
    field :no_of_done_children, :integer, default: 0
    belongs_to :parent, __MODULE__
    belongs_to :user, Todohai.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
