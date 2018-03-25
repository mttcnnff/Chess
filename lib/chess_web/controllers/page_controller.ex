defmodule ChessWeb.PageController do
  use ChessWeb, :controller

  import PhoenixGon.Controller
  alias Chess.Matches
  alias Chess.Matches.Game

  def index(conn, _params) do
    current_user = conn.assigns.current_user
  	if current_user do
      mygames = Matches.list_games_by_user_id(current_user.id);
  		render conn, "home.html", games: mygames
  	else
  		render conn, "index.html"
  	end
  end

  def game(conn, _params) do
    render conn, "game.html"
  end
end
