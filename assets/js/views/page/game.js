import chess_init from "./chess";

// function start() {
// 	let root = document.getElementById('root');
// 	if (root) {chess_init(root)};
// }

// $(start);


// web/static/js/views/page/index.js

import MainView from '../main';
import socket from '../../socket';

export default class View extends MainView {
  mount() {
    super.mount();

    let s = new socket();
    let channel = s.getChannel('games:' + window.Gon.getAsset('game_name'));

    let root = document.getElementById('root');
    if (root) {chess_init(root, channel)};

    // Specific logic here
    console.log('PageGameView mounted');
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('PageGameView unmounted');
  }
}