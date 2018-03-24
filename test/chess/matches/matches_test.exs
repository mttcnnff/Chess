defmodule Chess.MatchesTest do
  use Chess.DataCase

  alias Chess.Matches

  describe "games" do
    alias Chess.Matches.Game

    @valid_attrs %{black: 42, complete: true, name: "some name", white: 42}
    @update_attrs %{black: 43, complete: false, name: "some updated name", white: 43}
    @invalid_attrs %{black: nil, complete: nil, name: nil, white: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Matches.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Matches.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Matches.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Matches.create_game(@valid_attrs)
      assert game.black == 42
      assert game.complete == true
      assert game.name == "some name"
      assert game.white == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Matches.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.black == 43
      assert game.complete == false
      assert game.name == "some updated name"
      assert game.white == 43
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Matches.update_game(game, @invalid_attrs)
      assert game == Matches.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Matches.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Matches.change_game(game)
    end
  end
end
