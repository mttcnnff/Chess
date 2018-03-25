defmodule ChessWeb.GameController do
  use ChessWeb, :controller

  alias Chess.Matches
  alias Chess.Matches.Game
  alias Chess.Accounts
  alias Chess.Accounts.User

  action_fallback ChessWeb.FallbackController

  def index(conn, _params) do
    games = Matches.list_games()
    render(conn, "index.json", games: games)
  end

  def create(conn, %{"game" => game_params}) do
    with {:ok, %Game{} = game} <- Matches.create_game(game_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Matches.get_game!(id)
    render(conn, "show.json", game: game)
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Matches.get_game!(id)

    with {:ok, %Game{} = game} <- Matches.update_game(game, game_params) do
      render(conn, "show.json", game: game)
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Matches.get_game!(id)
    with {:ok, %Game{}} <- Matches.delete_game(game) do
      send_resp(conn, :no_content, "")
    end
  end

  def join_named_game(conn, %{"game_name" => game_name, "current_user" => current_user_name} = _params) do
    current_user = Accounts.get_user_by_name(current_user_name)
    game = Matches.get_named_game_to_join(current_user.id, game_name)

    case game do
      nil -> 
        conn
        |> send_resp(:not_found, "Couldn't find an open game by that name!")
      _ -> 
        Matches.update_game(game, %{white_id: current_user.id})
        conn
        |> send_resp(:ok, "Game joined!")
    end
  end

  def create_named_game(conn, %{"game_name" => game_name, "current_user" => current_user_name} = _params) do
    current_user = Accounts.get_user_by_name(current_user_name)
    game_params = %{name: game_name, black_id: current_user.id}

    case Matches.create_game(game_params) do
      {:ok, %Game{} = game} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", game_path(conn, :show, game))
        |> render("show.json", game: game)
      {:error, %Ecto.Changeset{} = changeset} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChessWeb.ChangesetView, "error.json", %{changeset: changeset})
    end
  end

  def join_random_game(conn, %{"current_user" => current_user_name} = _params) do
    current_user = Accounts.get_user_by_name(current_user_name)
    game = Matches.get_random_game_to_join(current_user.id)

    case game do
      nil -> 
        conn
        |> send_resp(:not_found, "Couldn't find an open game! Try creating your own and waiting for someone to join!")
      _ -> 
        Matches.update_game(game, %{white_id: current_user.id})
        conn
        |> send_resp(:ok, "Game joined!")
    end    
  end

end
