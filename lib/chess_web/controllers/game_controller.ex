defmodule ChessWeb.GameController do
  use ChessWeb, :controller

  alias Chess.Matches
  alias Chess.Matches.Game

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

  def join_named_game(conn, %{"game_name" => game_name} = _params) do
    result = Matches.get_game_by_name(game_name)
    case result do
      nil -> 
        conn
        |> send_resp(:not_found, "Game not found.")
      _ -> 
        conn
        |> send_resp(:not_found, "Game was found, but not joined.")
    end
  end

  def create_named_game(conn, %{"game_name" => game_name} = _params) do
    IO.puts("#{inspect(game_name)}")
    # game_name = params["game_name"]
    # result = Matches.get_game_by_name(game_name)
    # case result do
    #   nil -> 
    #     conn
    #     |> send_resp(:created, "Game not created... yet.")
    #   _ -> 
    #     conn
    #     |> send_resp(:no_content, "Game Already Exists.")
    # end

    conn
    |> send_resp(:created, "Game not created... yet.")
  end

  # def join_random_game(conn, params) do
  #   IO.puts("#{inspect(params)}")
  #   conn
  #   |> redirect(to: page_path(conn, :index))
  # end

end
