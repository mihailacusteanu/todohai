defmodule Todohai.Schema do
  @moduledoc """
  The Schema context.
  """

  import Ecto.Query, warn: false
  alias Todohai.Repo

  alias Todohai.Schema.Item

  @type item_id() :: Item.id()

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  List all items for a given parent item id.

  ## Examples

      iex> list_children_for_parent(parent_id1)
      [%Item{}, %Item{}}, ...]

      iex> list_children_for_parent(parent_id2)
      []

  """
  @spec list_children_for_parent(parent_id) :: result
        when result: [Item.t()],
             parent_id: item_id() | nil
  def list_children_for_parent(nil), do: []

  def list_children_for_parent(parent_id) do
    Repo.all(from i in Item, where: i.parent_id == ^parent_id)
  end

  @doc """
  List items marked as done for a given parent item id.

  ## Examples

      iex> list_done_children_for_parent(parent_id1)
      [%Item{is_done: true}, %Item{is_done: true}}, ...]

      iex> list_done_children_for_parent(parent_id2)
      []

  """
  @spec list_done_children_for_parent(parent_id) :: result
        when result: [Item.t()],
             parent_id: item_id() | nil
  def list_done_children_for_parent(nil), do: []

  def list_done_children_for_parent(parent_id) do
    Repo.all(from i in Item, where: i.parent_id == ^parent_id and i.is_done == true)
  end

  @doc """
  List items NOT marked as done for a given parent item id.

  ## Examples

      iex> list_not_done_children_for_parent(parent_id1)
      [%Item{is_done: true}, %Item{is_done: true}}, ...]

      iex> list_not_done_children_for_parent(parent_id2)
      []

  """
  @spec list_not_done_children_for_parent(parent_id) :: result
        when result: [Item.t()],
             parent_id: item_id() | nil
  def list_not_done_children_for_parent(nil), do: []

  def list_not_done_children_for_parent(parent_id) do
    Repo.all(from i in Item, where: i.parent_id == ^parent_id and i.is_done == false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
