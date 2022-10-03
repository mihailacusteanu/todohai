defmodule Todohai.Schema do
  @moduledoc """
  The Schema context.
  """

  import Ecto.Query, warn: false
  alias Todohai.Repo

  alias Todohai.Schema.Item

  @type item_id() :: Item.id()
  @type item() :: %Item{}

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    query = from i in Item, preload: [:parent]
    Repo.all(query)
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
    children = list_children_for_parent(item.id) |> Enum.map(fn it -> it.id end)

    if attrs[:parent_id] in children do
      {:error, {:update_item_error, "Parent item can't be child item"}}
    else
      item
      |> Item.changeset(attrs)
      |> Repo.update()
    end
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
        when result: [item()],
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
        when result: [item()],
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
        when result: [item()],
             parent_id: item_id() | nil
  def list_not_done_children_for_parent(nil), do: []

  def list_not_done_children_for_parent(parent_id) do
    Repo.all(from i in Item, where: i.parent_id == ^parent_id and i.is_done == false)
  end

  @spec add_child(item_id(), child_attrs) :: result
        when result: {:ok, item()} | {:error, Ecto.Changeset.t()},
             child_attrs: %{
               required(:name) => String.t(),
               required(:is_done) => boolean(),
               required(:no_of_children) => integer(),
               required(:no_of_done_children) => integer(),
               required(:no_of_not_done_children) => integer(),
               optional(:parent_id) => item_id()
             }
  def add_child(parent_id, child_attrs) do
    child_attrs = Map.merge(child_attrs, %{parent_id: parent_id})
    parent_item = get_item!(parent_id)

    %Item{}
    |> Item.changeset(child_attrs)
    |> Repo.insert()
    |> case do
      {:ok, child} ->
        parent_new_attrs = build_parent_attrs_after_add_child(child, parent_item)
        {:ok, _parent_item} = update_item(parent_item, parent_new_attrs)
        {:ok, child}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def build_parent_attrs_after_add_child(
        %{is_done: true} = _child,
        %{no_of_children: no_of_children, no_of_done_children: no_of_done_children} = _parent
      ),
      do: %{no_of_children: no_of_children + 1, no_of_done_children: no_of_done_children + 1}

  def build_parent_attrs_after_add_child(
        %{is_done: false} = _child,
        %{no_of_children: no_of_children, no_of_not_done_children: no_of_not_done_children} =
          _parent
      ),
      do: %{
        no_of_children: no_of_children + 1,
        no_of_not_done_children: no_of_not_done_children + 1
      }

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
