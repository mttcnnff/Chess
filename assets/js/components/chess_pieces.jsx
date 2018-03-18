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
      validPieces={props.validPieces} />
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
      validPieces: props.validPieces,
      selectedPiece: null
    };

    this.colorFilter = (num, color) => {
      return (this.state.pieces[num] ? this.state.pieces[num].color : "") != color;
    }

    this.filterValidPieces = (piece, validPieces) => {
      return _.chain(validPieces).filter(isValidCell).map(getSpace).filter((i) => this.colorFilter(i, piece.color)).value();
    }

    this.traverseWithDelta = (origin, delta) => {
      let traversedSpaces = [];
      let currCell = {row: origin.row + delta.row, col: origin.col + delta.col};
      while (isValidCell(currCell)) {
        traversedSpaces = traversedSpaces.concat(currCell);
        if (!_.isUndefined(this.state.pieces[getSpace(currCell)])) break;
        currCell = {row: currCell.row + delta.row, col: currCell.col + delta.col};
      }
      return traversedSpaces;
    }

    this.validPieceFunctions = {
      P: (piece, row, col) => {
        return piece.beenMoved ? [{row: row + piece.dir, col: col}] : [{row: row + 2*piece.dir, col: col}, {row: row + piece.dir, col: col}];
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
        return  this.traverseWithDelta({row: row, col: col}, {row: 1, col: 0})
                .concat(this.traverseWithDelta({row: row, col: col}, {row: -1, col: 0}))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: 0, col: 1}))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: 0, col: -1}));
      },
      B: (piece, row, col) => {
        return  this.traverseWithDelta({row: row, col: col}, {row: 1, col: 1})
                .concat(this.traverseWithDelta({row: row, col: col}, {row: -1, col: -1}))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: 1, col: -1}))
                .concat(this.traverseWithDelta({row: row, col: col}, {row: -1, col: 1}));
      },
      Q: (piece, row, col) => {
        return  this.validPieceFunctions.R(piece, row, col)
                .concat(this.validPieceFunctions.B(piece, row, col));
      }

    };
  }

  setValidPieces(piece, row, col) {
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

  toggleSelection(piece, row, col) {
    if (_.isUndefined(piece) || !isValidCell({row: row, col: col})) return;
    let i = getSpace({row: row, col: col});
    if (this.state.selectedPiece) {
      this.setState((prevState,props) => {
        return {selectedPiece: null}
      });
      this.setValidPieces(piece, row, col);
    } else {
      this.setState((prevState,props) => {
        return {selectedPiece: i}
      });
    }
  }

  render() {
    let pieces = this.state.pieces.map((piece, i) => {
      const row = Math.floor(i/8);
      const col = i%8;
      return <ChessPiece
                    key={i}
                    i={i}
                    row={row} 
                    col={col} 
                    piece={piece ? piece.piece: ''} 
                    size={this.state.spaceSize} 
                    color={piece ? piece.color: ''}
                    key={"piece"+i}
                    onMouseEnter={() => this.setValidPieces(piece, row, col)}
                    onMouseLeave={() => this.clearPieces(piece)}
                    onClick={() => this.toggleSelection(piece, row, col)}
                    isValid={this.state.validPieces.includes(i)}
                    isSelected={this.state.selectedPiece === i}
              />
    });
    return ( pieces );
  }
}