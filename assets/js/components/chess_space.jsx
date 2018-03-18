import React, { Component } from 'react';
import { Stage, Layer, Rect, Circle, Group, Text } from 'react-konva';

export default function ChessSpace(props) {
  return (
    <ChessSpaceComponent x={props.x} y={props.y} size={props.size} fill={props.fill} />
  );
}

class ChessSpaceComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      x: props.x,
      y: props.y,
      size: props.size,
      fill: props.fill,
    };
  }

  render() {
    return ( 
            <Group>
              <Rect
                    x={this.state.x} 
                    y={this.state.y} 
                    width={this.state.size} 
                    height={this.state.size} 
                    fill={ this.state.fill } 
                    /> 
            </Group>
            );
  }
}