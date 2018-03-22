import React from 'react';
import ReactDOM from 'react-dom';
import { Rect, Layer, Stage, Text, Image } from 'react-konva';
import ChessBoard from './components/chess_board';
import ChessPieces from './components/chess_pieces';

const startingPieces = ['R', 'Kn', 'B', 'Q', 'K', 'B', 'Kn', 'R'];
const startingPawns = _.chain(_.range(8)).map(() => 'P').value();
const startingEmpties = _.chain(_.range(32)).map(() => '').value();
let initialBoard = [startingPieces, startingPawns, startingEmpties, startingPawns, startingPieces.slice().reverse()];

initialBoard = _.flatten(initialBoard);
//initialBoard = _.shuffle(initialBoard);

let game = _.map(initialBoard, (piece, i) => {
  if (piece !== '') {
    return {piece: piece, color: i < 32 ? "white" : "black", dir: i < 32 ? 1 : -1, beenMoved: false}
  }
});



export default function chess_init(root) {
  ReactDOM.render(<ChessGame />, root);
}

class ChessGame extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      pieces: game,
      turn: false,
      validPieces: [],
      boardSize: 400
    };
  }

  render() {
    return (
      <div>
        <div className="row">
          <div className="col">
            <h2>Turn: {this.state.turn ? "white" : "black"}</h2>
          </div>
        </div>
        <div className="row">
          <div className="col">
            <Stage width={this.state.boardSize} height={this.state.boardSize}>
              <Layer>
                <ChessBoard  boardSize={this.state.boardSize} />
              </Layer>
              <Layer>
                <ChessPieces 
                  boardSize={this.state.boardSize} 
                  pieces={this.state.pieces} 
                  validPieces={this.state.validPieces} />
              </Layer>
            </Stage>
          </div>
        </div>
      </div>
    );
  }
}