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

	defp checkPawnMove(pieces, spaceFrom, spaceTo, delta) do
		cellFrom = getCell(spaceFrom)
		toPiece = pieces |> Enum.at(spaceTo)
		fromPiece = pieces |> Enum.at(spaceFrom)
		case toPiece do
			nil -> 
				case fromPiece.beenMoved do
					true -> 
						if delta.col == 0 && delta.row == fromPiece.dir do
							{:ok, ""}
						else
							{:error, "Invalid Move."}
						end
					false -> 
						if delta.col == 0 && delta.row == fromPiece.dir || delta.row == 2*fromPiece.dir do
							{:ok, ""}
						else
							{:error, "Invalid Move."}
						end
				end
			_ -> 
				if delta.row == fromPiece.dir && abs(delta.col) == 1 do
					{:ok , ""}
				else
					{:error , "Invalid Move."}
				end
		end
	end

	defp checkKingMove(pieces, spaceFrom, spaceTo, delta) do
		if abs(delta.col) < 2 && abs(delta.row) < 2 do
			{:ok , ""}
		else
			{:error , "Invalid Move."}
		end
	end

	defp checkRookMove(pieces, spaceFrom, spaceTo, delta) do
		if (delta.row == 0 && delta.col != 0) || (delta.row != 0 && delta.col == 0) do
			{:ok, ""}
		else
			{:error, "Invalid Move."}
		end
	end

	defp checkBishopMove(pieces, spaceFrom, spaceTo, delta) do
		if abs(delta.row) == abs(delta.col) do
			{:ok, ""}
		else
			{:error, "Invalid Move."}
		end
	end

	defp checkQueenMove(pieces, spaceFrom, spaceTo, delta) do
		{validBishopMove, msg} = checkBishopMove(pieces, spaceFrom, spaceTo, delta)
		{validRookMove, msg} = checkRookMove(pieces, spaceFrom, spaceTo, delta)
		if validBishopMove == :ok || validRookMove == :ok do
			{:ok, ""}
		else
			{:error, "Invalid Move"}
		end
	end

	defp checkKnightMove(pieces, spaceFrom, spaceTo, delta) do
		if abs(delta.row) == 1 && abs(delta.col) == 2 || abs(delta.row) == 2 && abs(delta.col) == 1 do
			{:ok, ""}
		else
			{:error, "Invalid Move"}
		end
	end

	defp validMove(pieces, spaceFrom, spaceTo) do
		fromPiece = pieces |> Enum.at(spaceFrom)
		cellFrom = getCell(spaceFrom)
		cellTo = getCell(spaceTo)
		delta = %{row: cellTo.row - cellFrom.row, col: cellTo.col - cellFrom.col}

		IO.puts("#{inspect(fromPiece)}")

		case fromPiece.piece do
			"P" -> checkPawnMove(pieces, spaceFrom, spaceTo, delta)
			"K" -> checkKingMove(pieces, spaceFrom, spaceTo, delta)
			"Q" -> checkQueenMove(pieces, spaceFrom, spaceTo, delta)
			"Kn" -> checkKnightMove(pieces, spaceFrom, spaceTo, delta)
			"R" -> checkRookMove(pieces, spaceFrom, spaceTo, delta)
			"B" -> checkBishopMove(pieces, spaceFrom, spaceTo, delta)
		end

	end

	defp take(pieces, spaceFrom, spaceTo) do
		fromPiece = pieces |> Enum.at(spaceFrom)
		toPiece = pieces |> Enum.at(spaceTo)

		if toPiece == nil do
			pieces
			|> List.update_at(spaceFrom, fn(x) -> toPiece end)
			|> List.update_at(spaceTo, fn(x) -> Map.put(fromPiece, :beenMoved, true) end)
		else
			pieces
			|> List.update_at(spaceFrom, fn(x) -> nil end)
			|> List.update_at(spaceTo, fn(x) -> fromPiece |> Map.put(:beenMoved, true) end)
		end

		
	end

	defp isMoveValid(pieces, spaceFrom, spaceTo) do
		fromPiece = pieces |> Enum.at(spaceFrom)
		toPiece = pieces |> Enum.at(spaceTo)

		with	{:ok, msg} <- validSpace(fromPiece, toPiece),
				{:ok, msg} <- validMove(pieces, spaceFrom, spaceTo)
		do
			{:ok, ""}
		else
			{:error, msg} -> {:error, msg}
		end
	end

	defp validSpace(pieceFrom, pieceTo) do
		if pieceTo == nil || pieceFrom.color != pieceTo.color do
			{:ok, ""}
		else
			{:error, "You can't move there!"}
		end
	end

	defp pieceCheck(user_id, fromPieceOwner) do
		case user_id == fromPieceOwner do
	    	true -> {:ok, ""}
	    	false -> {:error, "That's not your piece!"}
	    end
	end

	defp turnCheck(user_id, current_player_id) do
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

	def move(user_id, game_name, game, spaceFrom, spaceTo) do
		with	{:ok, msg} <- playerCheck(user_id, spaceFrom, game, game_name),
				{:ok, msg} <- isMoveValid(game.pieces, spaceFrom, spaceTo)
		do
				game = game
				|> Map.put(:pieces, game.pieces |> take(spaceFrom, spaceTo))
				|> Map.put(:turn, otherColor(game.turn))
				IO.puts("#{inspect(game.turn)}")
				{:ok, game}

		else
			{:error, msg} -> {:error, msg}
		end
	end

end