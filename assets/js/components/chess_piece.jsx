import React, { Component } from 'react';
import { Stage, Layer, Rect, Circle, Group, Text } from 'react-konva';

export default function ChessPiece(props) {
  return (
    <Group>
      <Rect key={props.i}
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
      <Text x={props.col * props.size + (props.size/2)} 
            y={props.row * props.size + (props.size/2)} 
            width={100}
            text={props.piece}
            fill={props.color}
            onMouseEnter={props.piece ? () => props.onMouseEnter(props.piece, props.row, props.col) : () => {}}
            onMouseLeave={() => props.onMouseLeave()}
            onClick={() => props.onClick(props.piece, props.row, props.col)}
      />
    </Group>
                          
  );
} 