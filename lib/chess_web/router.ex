defmodule ChessWeb.Router do
  use ChessWeb, :router

  import PhoenixGon.Controller

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :get_current_user
    plug :put_user_token
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  defp get_current_user(conn, _params) do
    # TODO: Move this function out of the router module.
    user_id = get_session(conn, :user_id)
    user = Chess.Accounts.get_user(user_id || -1)

    conn = 
    case user_id do
      nil -> put_gon(conn, current_user: nil)
      _ -> put_gon(conn, current_user: user.name)
    end

    conn
    |> assign(:current_user, user)
  end

  defp put_user_token(conn, _) do
       if current_user = conn.assigns[:current_user] do
         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
         conn
         |> assign(:user_token, token)
         |> put_gon(user_token: token)
       else
         conn
         |> put_gon(user_token: nil)
       end
     end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChessWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/game/:game", PageController, :game
    resources "/users", UserController, except: [:edit]


    post "/session", SessionController, :create
    delete "/session", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  scope "/api", ChessWeb do
    pipe_through :api
    resources "/games", GameController, except: [:new, :edit]
    post "/join_named_game", GameController, :join_named_game
    post "/create_named_game", GameController, :create_named_game
    post "/join_random_game", GameController, :join_random_game


  end
end
