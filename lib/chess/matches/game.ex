defmodule Chess.Matches.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chess.Matches.Game

  alias Chess.Accounts.User


  schema "games" do
    field :name, :string
    field :complete, :boolean, default: false
    belongs_to :white, User
    belongs_to :black, User
    belongs_to :winner, User

    timestamps()
  end

  @doc false
  def changeset(%Game{} = game, attrs) do
    game
    |> cast(attrs, [:name, :complete, :black_id, :white_id, :winner_id])
    |> validate_required([:name, :black_id])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:white_id)
    |> foreign_key_constraint(:black_id)
    |> foreign_key_constraint(:winner_id)
  end
end
