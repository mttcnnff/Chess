defmodule Chess.Game do

	alias Chess.Matches

	def new do
		%{
			pieces: getInitialGamePieces(),
			turn: "white",
			status: "ongoing"
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
		status = game.status
		%{
			pieces: pieces,
			turn: turn,
			status: status
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

	defp checkForPromotion(pieces, spaceTo) do
		piece = pieces |> Enum.at(spaceTo)
		toCell = getCell(spaceTo)
		if toCell.row == 0 && piece.color == "black" || toCell.row == 7 && piece.color == "white" do
			pieces
			|> List.update_at(spaceTo, fn(x) -> piece |> Map.put(:piece, "Q") end)
		else
			pieces
		end
	end

	defp checkPieceCount(pieces) do
		actualPieces = pieces |> Enum.filter(fn(piece) -> !is_nil(piece) end)
		blackPieces = actualPieces |> Enum.filter(fn(piece) -> piece.color == "black" end)
		whitePieces = actualPieces |> Enum.filter(fn(piece) -> piece.color == "white" end)

		cond do
			length(blackPieces) < 2 -> {:error, ""}
			length(whitePieces) < 2
			true -> {:ok, ""}
		end
	end

	defp checkForGameEnd(game, game_name) do
		pieces = game.pieces
		actualPieces = pieces |> Enum.filter(fn(piece) -> !is_nil(piece) end)
		blackPieces = actualPieces |> Enum.filter(fn(piece) -> piece.color == "black" end)
		whitePieces = actualPieces |> Enum.filter(fn(piece) -> piece.color == "white" end)
		blackKing = blackPieces |> Enum.find(fn(piece) -> piece.piece == "K" end)
		IO.puts("Black King: #{inspect(blackKing)}")
		IO.puts("Black Pieces: #{inspect(length(blackPieces))}")
		blackPieces |> Enum.each(fn(x) -> IO.puts("#{inspect(x)}") end)
		whiteKing = whitePieces |> Enum.find(fn(piece) -> piece.piece == "K" end)
		IO.puts("White King: #{inspect(whiteKing)}")
		IO.puts("White Pieces: #{inspect(length(whitePieces))}")

		cond do
			length(blackPieces) < 2 || is_nil(blackKing) ->
				endGameWhite(game_name, game)
			length(whitePieces) < 2 || is_nil(whiteKing) ->
				endGameBlack(game_name, game)
			true -> 
				game
		end
	
	end

	defp take(pieces, spaceFrom, spaceTo) do
		fromPiece = pieces |> Enum.at(spaceFrom)
		toPiece = pieces |> Enum.at(spaceTo)
		pieces =
			case toPiece do
				nil ->
					pieces
					|> List.update_at(spaceFrom, fn(x) -> toPiece end)
					|> List.update_at(spaceTo, fn(x) -> Map.put(fromPiece, :beenMoved, true) end)
				_ ->
					pieces
					|> List.update_at(spaceFrom, fn(x) -> nil end)
					|> List.update_at(spaceTo, fn(x) -> fromPiece |> Map.put(:beenMoved, true) end)
			end

		pieces = 
			case fromPiece.piece do
				"P" -> pieces |> checkForPromotion(spaceTo)
				_ -> pieces
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
				game = 
					game
					|> Map.put(:pieces, game.pieces |> take(spaceFrom, spaceTo))
					|> Map.put(:turn, otherColor(game.turn))
					|> checkForGameEnd(game_name)
				{:ok, game}

		else
			{:error, msg} -> {:error, msg}
		end
	end

	defp endGame(winner_id, game_name, game) do
		dbgame = Matches.get_game_by_name(game_name)
		black_id = dbgame.black_id
		white_id = dbgame.white_id

		case winner_id do
			^black_id ->
				Matches.update_game(dbgame, %{winner_id: black_id, complete: true})
				game |> Map.put(:status, "completed")
			^white_id ->
				Matches.update_game(dbgame, %{winner_id: white_id, complete: true})
				game |> Map.put(:status, "completed")
			_ -> game
		end
	end

	defp endGameWhite(game_name, game) do
		dbgame = Matches.get_game_by_name(game_name)
		black_id = dbgame.black_id
		white_id = dbgame.white_id

		Matches.update_game(dbgame, %{winner_id: white_id, complete: true})
		game |> Map.put(:status, "completed")
	end

	defp endGameBlack(game_name, game) do
		dbgame = Matches.get_game_by_name(game_name)
		black_id = dbgame.black_id
		white_id = dbgame.white_id

		Matches.update_game(dbgame, %{winner_id: black_id, complete: true})
		game |> Map.put(:status, "completed")
	end

	def forfeit(user_id, game_name, game) do
		dbgame = Matches.get_game_by_name(game_name)
		black_id = dbgame.black_id
		white_id = dbgame.white_id

		case user_id do
			^black_id ->
				endGame(white_id, game_name, game)
			^white_id ->
				endGame(black_id, game_name, game)
			_ -> game
		end
	end

	

end