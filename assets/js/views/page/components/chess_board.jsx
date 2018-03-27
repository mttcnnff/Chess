import React, { Component } from 'react';
import { Stage, Layer, Rect, Circle } from 'react-konva';
import ChessSpace from './chess_space';

export default function ChessBoard(props) {
  return (
    <ChessBoardComponent boardSize={props.boardSize} spaceSize={props.boardSize/8} />
  );
}

class ChessBoardComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      boardSize: props.boardSize,
      spaceSize: props.spaceSize,
    };
  }

  render() {
    let spaces = _.range(64).map((i) => {
      const row = Math.floor(i/8);
      const col = i%8;
      return <ChessSpace  
                    key={"space"+i} 
                    x={col * this.state.spaceSize} 
                    y={row * this.state.spaceSize} 
                    size={this.state.spaceSize} 
                    fill={ (row + col) % 2  == 0 ? "SaddleBrown" : "SandyBrown"} 
              />
    });
    return ( spaces );
  }
}
