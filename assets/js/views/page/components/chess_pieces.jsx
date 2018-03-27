import React, { Component } from 'react';
import { Stage, Layer, Rect, Circle } from 'react-konva';
import ChessPiece from './chess_piece';

export default function ChessPieces(props) {
  return (
    <ChessPiecesComponent   
      key={"pieces"} 
      boardSize={props.boardSize} 
      spaceSize={props.boardSize/8} 
      pieces={props.pieces} 
      validPieces={props.validPieces}
      channel={props.channel}
      callSocket={props.callSocket} />
  );
}

function isValidCell(cell) {
  return 0 <= cell.row && 7 >= cell.row && 0 <= cell.col && 7 >= cell.col;
}

function getSpace(cell) {
  return cell.row * 8 + cell.col;
}

class ChessPiecesComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      boardSize: props.boardSize,
      spaceSize: props.spaceSize,
      pieces: props.pieces,
      validPieces: [],
      selectedPiece: null,
      channel: props.channel,
      callSocket: props.callSocket,
    };

    this.colorFilter = (num, color) => {
      let val = (this.state.pieces[num] ? this.state.pieces[num].color : "") != color;
      return val;
    }

    this.filterValidPieces = (piece, validPieces) => {
      let vp = _.chain(validPieces).filter(isValidCell).map(getSpace).filter((i) => this.colorFilter(i, piece.color)).value();
      return vp;
    }

    this.traverseWithDelta = (origin, delta, n) => {
      let traversedSpaces = [];
      let currCell = {row: origin.row + delta.row, col: origin.col + delta.col};
      let i = 0;
      while (isValidCell(currCell) && i < n) {
        traversedSpaces = traversedSpaces.concat(currCell);
        if (!_.isNull(this.state.pieces[getSpace(currCell)])) break;
        currCell = {row: currCell.row + delta.row, col: currCell.col + delta.col};
        i++;
      }
      return traversedSpaces;
    }

    this.validPieceFunctions = {
      P: (piece, row, col) => {
        let moves = [];
        if (_.isNull(this.state.pieces[getSpace({row: row + piece.dir, col: col})])) {
          moves = piece.beenMoved ? this.traverseWithDelta({row: row, col: col}, {row: piece.dir, col: 0}, 1) : this.traverseWithDelta({row: row, col: col}, {row: piece.dir, col: 0}, 2);
        }
        let left = {row: row + piece.dir, col: col - 1};
        let right = {row: row + piece.dir, col: col + 1};
        if (!_.isNull(this.state.pieces[getSpace(left)])) moves = moves.concat(left);
        if (!_.isNull(this.state.pieces[getSpace(right)])) moves = moves.concat(right);
        return moves;
      },
      K: (piece, row, col) => {
        return [
        {row: row + 1, col: col}, 
        {row: row - 1, col: col}, 
        {row: row, col: col + 1}, 
        {row: row, col: col - 1},
        {row: row + 1, col: col + 1},
        {row: row + 1, col: col - 1},
        {row: row - 1, col: col + 1},
        {row: row - 1, col: col - 1},
        ];
      },
      Kn: (piece, row, col) => {
        return [
        {row: row + 2, col: col + 1}, 
        {row: row + 2, col: col - 1},
        {row: row - 2, col: col + 1}, 
        {row: row - 2, col: col - 1},
        {row: row + 1, col: col + 2}, 
        {row: row + 1, col: col - 2},
        {row: row - 1, col: col + 2}, 
        {row: row - 1, col: col - 2},   
        ];
      },
      R: (piece, row, col) => {
        return  this.traverseWithDelta({row: row, col: col}, {row: 1, col: 0}, 20)
                .concat(this.traverseWithDelta({row: row, col: col}, {row: -1, col: 0}, 20))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: 0, col: 1}, 20))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: 0, col: -1}, 20));
      },
      B: (piece, row, col) => {
        return  this.traverseWithDelta({row: row, col: col}, {row: 1, col: 1}, 20)
                .concat(this.traverseWithDelta({row: row, col: col}, {row: -1, col: -1}, 20))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: 1, col: -1}, 20))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: -1, col: 1}, 20));
      },
      Q: (piece, row, col) => {
        return  this.validPieceFunctions.R(piece, row, col)
                .concat(this.validPieceFunctions.B(piece, row, col));
      }

    };
  }

  setValidPieces(row, col) {
    let piece = this.state.pieces[getSpace({row: row, col: col})];
    if (_.isUndefined(piece)) {
      this.setState({validPieces: []});
      return;
    }
    if (this.state.selectedPiece == null) {
      this.setState((prevState,props) => {
        return {validPieces: this.filterValidPieces(piece, this.validPieceFunctions[piece.piece](piece, row, col))}
      });
    }
  }

  clearPieces(piece) {
    if (this.state.selectedPiece == null) {
      this.setState((prevState,props) => {
        return {validPieces: []}
      });
    }
  }

  move(spaceFrom, spaceTo) {
    this.state.callSocket("move", {spaceFrom: spaceFrom, spaceTo: spaceTo});
  }


  handleClick(row, col) {
    let current_user = window.Gon.getAsset('current_user');
    if (!isValidCell({row: row, col: col}) || _.isNull(current_user)) return;
    let cell = getSpace({row: row, col: col});

    if (this.state.validPieces.includes(cell)) {
      this.move(this.state.selectedPiece, cell);
    } else if (this.state.selectedPiece) {
      this.setState({selectedPiece: null});
    } else {
      this.setState({selectedPiece: cell});
    }
    this.setValidPieces(row, col);
  }

  componentWillReceiveProps(nextProps) {
    console.log(nextProps);
    this.setState(nextProps);
  }

  render() {
    let pieces = this.state.pieces.map((piece, i) => {
      const row = Math.floor(i/8);
      const col = i%8;
      const p = piece ? piece.piece : "empty";
      return <ChessPiece
                    key={p + row + col}
                    i={i}
                    row={row} 
                    col={col} 
                    piece={piece ? piece.piece: ''} 
                    size={this.state.spaceSize} 
                    color={piece ? piece.color: ''}
                    onMouseEnter={() => this.setValidPieces(row, col)}
                    onMouseLeave={() => this.clearPieces(piece)}
                    onClick={() => this.handleClick(row, col)}
                    isValid={this.state.validPieces.includes(i)}
              />
    });
    return ( pieces );
  }
}