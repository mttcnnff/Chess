// web/static/js/views/main.js

export default class MainView {
  mount() {
    // This will be executed when the document loads...
    console.log('MainView mounted');
  }

  unmount() {
    // This will be executed when the document unloads...
    console.log('MainView unmounted');
  }

  flashAlert(text) {
    $("#alert-block").children()[0].innerHTML = text;
    $("#alert-block")[0].className = "";
  }

  flashDanger(text) {
    $("#danger-block").children()[0].innerHTML = text;
    $("#danger-block")[0].className = "";
  }
};
