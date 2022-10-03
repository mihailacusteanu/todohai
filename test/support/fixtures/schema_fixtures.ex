defmodule Todohai.SchemaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todohai.Schema` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        is_done: true,
        name: "some name"
      })
      |> Todohai.Schema.create_item()

    item
  end
end
