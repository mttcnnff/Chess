defmodule Chess.Game do
    # strongly based off of the Hangman example from class. thanks, prof. tuck!
    def new do
        %{
          pieces: make_board(),
          turn: false,
          validPieces: [],
          boardSize: 400,
        }
    end

     def client_view(game) do
        pc = game.pieces
        tn = game.turn
        vldpc = game.validPieces
        bdsz = game.boardSize
        %{
            pieces: pc,
            turn: tn,
            validPieces: vldpc,
            boardSize: bdsz,
        }
    end

    def move() do
      []
    end

    def make_board() do
      []
    end




end

