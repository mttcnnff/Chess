defmodule ChessWeb.GameView do
  use ChessWeb, :view
  alias ChessWeb.GameView

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{id: game.id,
      name: game.name,
      white: game.white,
      black: game.black,
      complete: game.complete}
  end
end
