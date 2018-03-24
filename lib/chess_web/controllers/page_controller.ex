defmodule ChessWeb.PageController do
  use ChessWeb, :controller

  import PhoenixGon.Controller
  alias Chess.Matches
  alias Chess.Matches.Game

  def index(conn, _params) do
  	if conn.assigns.current_user do
  		render conn, "home.html"
  	else
  		render conn, "index.html"
  	end
  end

  def game(conn, _params) do
    render conn, "game.html"
  end
end
