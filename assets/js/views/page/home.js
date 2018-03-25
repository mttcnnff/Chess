// web/static/js/views/page/home.js

import MainView from '../main';
import * as Alerts from '../alerts';

function joinNamedGame() {
  const formData = $('#join-named-game').serialize();
  const data = formData + '&current_user=' + window.Gon.getAsset('current_user')
  $.ajax('/api/join_named_game', {
            type: 'post',
            data: data,
            success: (resp) => {location.reload()},
            error: (resp) => {Alerts.flashDanger("Failed - " + resp.responseText); },
  });
}

function createNamedGame() {
  const formData = $('#create-named-game').serialize();
  const data = formData + '&current_user=' + window.Gon.getAsset('current_user')
  $.ajax('/api/create_named_game', {
            type: 'post',
            data: data,
            success: (resp) => {location.reload()},
            error: (resp) => {Alerts.flashDanger("Failed - " + resp.responseText)},
  });
}

function joinRandomGame() {
  const data = 'current_user=' + window.Gon.getAsset('current_user')
  $.ajax('/api/join_random_game', {
            type: 'post',
            data: data,
            success: (resp) => {location.reload()},
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

    $('#join-random-game').submit(function(event) {
        event.preventDefault();
        joinRandomGame();
    });

  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('PageHomeView unmounted');
  }
}