// web/static/js/views/page/home.js

import MainView from '../main';
import * as Alerts from '../alerts';

function joinNamedGame() {
  const formData = $('#join-named-game').serialize();
  $.ajax('/api/join_named_game', {
            type: 'post',
            data: formData,
            success: (resp) => {Alerts.flashAlert("Game Joined!")},
            error: (resp) => {Alerts.flashDanger("Failed - " + resp.responseText)},
  });
}

function createNamedGame() {
  const formData = $('#create-named-game').serialize();
  $.ajax('/api/create_named_game', {
            type: 'post',
            data: formData,
            success: (resp) => {Alerts.flashAlert("Game Created!")},
            error: (resp) => {Alerts.flashDanger("Failed - " + resp.responseText)},
  });
}

export default class View extends MainView {



  mount() {
    super.mount();
    console.log('PageHomeView mounted');

    $('#join-named-game').submit(function(event) {
        event.preventDefault();
        joinNamedGame();
    });

    $('#create-named-game').submit(function(event) {
        event.preventDefault();
        createNamedGame();
    });

  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('PageHomeView unmounted');
  }
}