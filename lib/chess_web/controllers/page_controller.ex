defmodule ChessWeb.PageController do
  use ChessWeb, :controller

  import PhoenixGon.Controller
  alias Chess.Matches
  alias Chess.Matches.Game

  def index(conn, _params) do
    current_user = conn.assigns.current_user
  	if current_user do
      my_games = Matches.list_games_by_user_id(current_user.id);
  		render conn, "home.html", games: my_games
  	else
  		render conn, "index.html"
  	end
  end

  def game(conn, params) do
    game_name = params["game"]
    game = Matches.get_game_by_name(game_name)
    black_id = game.black_id
    white_id = game.white_id
    
    if game do
      if black_id == nil || white_id == nil do
        render conn, "pregame.html", game: game_name
      else
        current_user = conn.assigns.current_user
        user_color = 
          case current_user do
            nil -> nil
            _ -> 
              case current_user.id do
                ^black_id -> "black"
                ^white_id -> "white"
                _-> nil
              end
          end

        render(
        conn 
        |> put_gon(game_name: game_name) 
        |> put_gon(user_color: user_color)
        |> put_gon(black_player: game.black.name)
        |> put_gon(white_player: game.white.name),
        "game.html",
        game: game_name)        
      end
    else
      render conn, "nogame.html", game: game_name
    end

    
  end
end
