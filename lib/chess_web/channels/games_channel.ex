defmodule ChessWeb.GamesChannel do
  use ChessWeb, :channel

  alias Chess.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Chess.GameBackup.load(name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      Chess.GameBackup.save(socket.assigns[:name], game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("move", payload, socket) do
    game = Game.move(socket.assigns[:game], payload)
    socket = assign(socket, :game, game)
    Chess.GameBackup.save(socket.assigns[:name], game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
