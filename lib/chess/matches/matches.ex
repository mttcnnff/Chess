defmodule Chess.Matches do
  @moduledoc """
  The Matches context.
  """

  import Ecto.Query, warn: false
  alias Chess.Repo

  alias Chess.Matches.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  def list_games_by_user_id(user_id) do
    query = from g in Game, where: g.black_id == ^user_id or g.white_id == ^user_id,
    select: g
    Repo.all(query) |> Repo.preload(:black) |> Repo.preload(:white) |> Repo.preload(:winner)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game(id), do: Repo.get(Game, id) |> Repo.preload(:black)
  def get_game!(id), do: Repo.get!(Game, id)
  def get_game_by_name(name) do
    Repo.get_by(Game, name: name) |> Repo.preload(:black) |> Repo.preload(:white) |> Repo.preload(:winner)
  end

  def get_named_game_to_join(user_id, name) do
    query = from g in Game, where: g.black_id != ^user_id and is_nil(g.white_id) and g.name == ^name
    query |> first(:id) |> Repo.one
  end

  def get_random_game_to_join(user_id) do
    query = from g in Game, where: g.black_id != ^user_id and is_nil(g.white_id)
    query |> first(:id) |> Repo.one
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end
end
