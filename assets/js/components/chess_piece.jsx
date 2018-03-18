import React, { Component } from 'react';
import { Stage, Layer, Rect, Circle, Group, Text, Image } from 'react-konva';

class PieceImage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      image: null,
      src: props.src,
      x: props.x,
      y: props.y,
      size: props.size,
      onMouseEnter: props.onMouseEnter,
      onMouseLeave: props.onMouseLeave,
      onClick: props.onClick
    };
  }

  componentDidMount() {
    const image = new window.Image();
    image.src = this.state.src;
    image.onload = () => {
      // setState will redraw layer
      // because "image" property is changed
      this.setState({
        image: image
      });
    };
  }

  render() {
    return <Image 
              image={this.state.image} 
              x={this.state.x} 
              y={this.state.y} 
              width={this.state.size} 
              height={this.state.size} 
              onMouseEnter={this.state.onMouseEnter}
              onMouseLeave={this.state.onMouseLeave}
              onClick={this.state.onClick} />;
  }
}

export default function ChessPiece(props) {
  //onClick={() => props.onClick(props.piece, props.row, props.col)}
  let bckRect = <Rect key={props.i}
                  x={props.col * props.size}
                  y={props.row * props.size}
                  width={props.size}
                  height={props.size}
                  fill={props.piece ? "red" : "green"}
                  opacity={props.isValid == true ? .50 : 0}
                  onMouseEnter={props.piece ? () => props.onMouseEnter(props.piece, props.row, props.col) : () => {}}
                  onMouseLeave={() => props.onMouseLeave()}
                  onClick={() => props.onClick(props.piece, props.row, props.col)}
                  />
  let pieceImage;

  if (props.piece !== "") {
    pieceImage = <PieceImage 
                    src={"images/pieces/" + props.color + "/" + props.piece + ".svg"} 
                    x={props.col * props.size} 
                    y={props.row * props.size} 
                    size={props.size} 
                    onMouseEnter={props.piece ? () => props.onMouseEnter(props.piece, props.row, props.col) : () => {}}
                    onMouseLeave={() => props.onMouseLeave()}
                    onClick={() => props.onClick(props.piece, props.row, props.col)} />
  }
  
  return (
    <Group>
      {bckRect}
      {pieceImage}
    </Group>
                          
  );
} 