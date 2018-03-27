import React from 'react';
import ReactDOM from 'react-dom';
import { Rect, Layer, Stage, Text, Image } from 'react-konva';
import ChessBoard from './components/chess_board';
import ChessPieces from './components/chess_pieces';
import * as Alerts from '../alerts';

// const startingPieces = ['R', 'Kn', 'B', 'Q', 'K', 'B', 'Kn', 'R'];
// const startingPawns = _.chain(_.range(8)).map(() => 'P').value();
// const startingEmpties = _.chain(_.range(32)).map(() => '').value();
// let initialBoard = [startingPieces, startingPawns, startingEmpties, startingPawns, startingPieces.slice().reverse()];

// initialBoard = _.flatten(initialBoard);
// //initialBoard = _.shuffle(initialBoard);

// let game = _.map(initialBoard, (piece, i) => {
//   if (piece !== '') {
//     return {piece: piece, color: i < 32 ? "white" : "black", dir: i < 32 ? 1 : -1, beenMoved: false}
//   }
// });

export default function chess_init(root, channel) {
  ReactDOM.render(<ChessGame channel={channel} />, root);
}

class ChessGame extends React.Component {
  constructor(props) {
    super(props);
    //this.channel = props.channel;

    this.state = {
      channel: props.channel,
      pieces: [],
      validPieces: [],
      boardSize: 400
    };

    this.state.channel.join()
      .receive("ok", resp => {
        this.setState({
          pieces: resp.game.pieces,
          turn: resp.game.turn,
          validPieces: [],
          gameStatus: resp.game.status
        });
      })
      .receive("error", resp => { console.log("Unable to join", resp) });

    this.state.channel.on("game_update", resp => {
      console.log(resp);
      this.setState({
        pieces: resp.pieces,
        turn: resp.turn,
        validPieces: [],
        gameStatus: resp.status,
      });
})
  }

  callSocket(functionName, payload) {
    let user_token = window.Gon.getAsset('user_token');
    if (!_.isNull(user_token)) {
      payload["user_token"] = user_token;
      this.state.channel.push(functionName, payload)
        .receive("error", resp => {console.log(resp); Alerts.flashDanger(resp.msg);})
      }
  }

  getTurnDisplay() {
    if (!_.isNull(window.Gon.getAsset('current_user'))) {
      return this.state.turn == window.Gon.getAsset('user_color') ? "Your move!" : "Waiting for your opponent...";
    } else {
      return "Spectating.";
    }
  }

  forfeit() {
    if (this.state.gameStatus !== "ongoing") return;
    this.callSocket("forfeit", {});
  }

  render() {
    let current_user = window.Gon.getAsset("current_user");
    let black_player = window.Gon.getAsset("black_player");
    let white_player = window.Gon.getAsset("white_player");
    let forfeitButton = 
    ((current_user == black_player || current_user == white_player) && this.state.gameStatus == "ongoing") 
    ? <button className="btn btn-danger" onClick={() =>this.forfeit()}>Forfeit</button> 
    : "";

    return (
      <div>
        <div className="row">
          <div className="d-flex col justify-content-center">
            <h2>{this.getTurnDisplay()}</h2>
          </div>
        </div>
        <div className="row">
          <div className="d-flex col justify-content-center">
            <Stage width={this.state.boardSize} height={this.state.boardSize}>
              <Layer>
                <ChessBoard  boardSize={this.state.boardSize} />
              </Layer>
              <Layer>
                <ChessPieces 
                  channel={this.state.channel}
                  callSocket={(functionName, payload) => this.callSocket(functionName, payload)}
                  boardSize={this.state.boardSize} 
                  pieces={this.state.pieces} 
                  validPieces={this.state.validPieces}
                  gameStatus={this.state.gameStatus}
                  />
              </Layer>
            </Stage>
          </div>
        </div>
        <div className="row">
            <div className="d-flex col justify-content-center">
              <h4>{current_user ? "Your color: " + window.Gon.getAsset("user_color") : ""}</h4>
            </div>
            <div className="d-flex col justify-content-center">
              <h4>{"Game Status: " + this.state.gameStatus}</h4>
            </div>
        </div>
        <div className="row">
            <div className="d-flex col justify-content-center">
             { forfeitButton }
            </div>
        </div>

      </div>
    );
  }
}