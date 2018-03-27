defmodule Chess.Game do

	alias Chess.Matches

	def new do
		%{
			pieces: getInitialGamePieces(),
			turn: "white",
		}
	end

	defp getInitialGamePieces do
		indexes = 0..63 |> Enum.to_list()
		startingPieces = ["R", "Kn", "B", "Q", "K", "B", "Kn", "R"]
		startingPawns = List.duplicate("P", 8)
		startingEmpties = List.duplicate("", 32)
		initialBoard = startingPieces ++ startingPawns ++ startingEmpties ++ startingPawns ++ Enum.reverse(startingPieces)

		indexes
		|> Enum.zip(initialBoard)
		|> Enum.map(fn {index, piece} -> 
			case piece do
				"" -> nil
				_ -> %{
						piece: piece,
					 	beenMoved: false, 
					 	color: (if (index < 32), do: "white", else: "black"),
					 	dir: (if (index < 32), do: 1, else: -1)
					}
			end
		end)
	end

	def client_view(game) do
		pieces = game.pieces
		turn = game.turn
		%{
			pieces: pieces,
			turn: turn
		}
	end

	defp getSpace(cell) do
		cell.row * 8 + cell.col
	end

	defp getCell(space) do
		%{
			row: div(space, 8),
			col: rem(space, 8)
		}
	end

	defp otherColor(turn) do
		case turn do
			"white" -> "black"
			"black" -> "white"
		end
	end

	# defp isMoveValid(game, spaceFrom, spaceTo) {
	# 	fromPiece = game.pieces |> Enum.at(spaceFrom)
	# 	toPiece = game.pieces |> Enum.at(spaceTo)

	# }

	defp pieceCheck(user_id, fromPieceOwner) do
		case user_id == fromPieceOwner do
	    	true -> {:ok, ""}
	    	false -> {:error, "That's not your piece!"}
	    end
	end

	defp turnCheck(user_id, current_player_id) do
		IO.puts("USER_ID: #{inspect(user_id)}")
		IO.puts("TURN_ID: #{inspect(current_player_id)}")
		case user_id == current_player_id do
	    	true -> {:ok, ""}
	    	false -> {:error, "It's not your turn!"}
	    end
	end

	defp playerCheck(user_id, spaceFrom, game, game_name) do
	    dbgame = Matches.get_game_by_name(game_name)
	    fromPiece = game.pieces |> Enum.at(spaceFrom)
	    fromPieceOwner = Map.get(dbgame, String.to_atom(fromPiece.color)).id
	    blackPlayer = dbgame.black
	    whitePlayer = dbgame.white

	    with 	{:ok, msg} <- turnCheck(user_id, Map.get(dbgame, String.to_atom(game.turn)).id),
	    		{:ok, msg} <- pieceCheck(user_id, fromPieceOwner)
	    do
	    	{:ok, "good"}
	    else
	    	{:error, msg} -> {:error, msg}
	    end
	  end

	defp swap(pieces, spaceFrom, spaceTo) do
		fromPiece = pieces |> Enum.at(spaceFrom)
		toPiece = pieces |> Enum.at(spaceTo)

		pieces
		|> List.update_at(spaceFrom, fn(x) -> toPiece end)
		|> List.update_at(spaceTo, fn(x) -> Map.put(fromPiece, :beenMoved, true) end)
	end

	def move(user_id, game_name, game, spaceFrom, spaceTo) do
		case playerCheck(user_id, spaceFrom, game, game_name) do
			{:ok, msg} -> 
				game = game
				|> Map.put(:pieces, game.pieces |> swap(spaceFrom, spaceTo))
				|> Map.put(:turn, otherColor(game.turn))
				IO.puts("#{inspect(game.turn)}")
				{:ok, game}
			{:error, msg} -> {:error, msg}
		end	
	end

end