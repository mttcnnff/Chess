defmodule ChessWeb.UserView do
  use ChessWeb, :view
  alias ChessWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      name: user.name}
  end

  def render("scripts.html", _assigns) do
    ~s{<script>require("/js/js/test").Test.run()</script>}
    |> raw
  end
end
