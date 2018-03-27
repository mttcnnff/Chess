defmodule ChessWeb.GamesChannel do
  use ChessWeb, :channel

  alias Chess.Game

  def max_age, do: 2592000

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Chess.GameBackup.load(name) || Game.new()
      Chess.GameBackup.save(name, game)
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("move", %{"spaceFrom" => spaceFrom, "spaceTo" => spaceTo, "user_token" => token}, socket) do
    # Phoenix.Token.sign(conn, "user socket", current_user.id)
    case Phoenix.Token.verify(socket, "user socket", token, max_age: max_age) do
      {:ok, user_id} ->
        IO.puts("SOCKET TURN: #{inspect(socket.assigns[:game].turn)}")
        name = socket.assigns[:name]
        case Game.move(user_id, name, Chess.GameBackup.load(name), spaceFrom, spaceTo) do
          {:ok, game} -> 
            Chess.GameBackup.save(socket.assigns[:name], game)
            socket = assign(socket, :game, game)
            broadcast(socket, "game_update", game)
            {:reply, {:ok, %{msg: "Move executed."}}, socket}
          {:error, reason} ->
            {:reply, {:error, %{msg: reason}}, socket}
        end
      {:error, reason} -> 
          {:reply, {:error, %{msg: reason}}, socket}
    end      
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
