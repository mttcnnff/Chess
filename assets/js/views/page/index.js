// web/static/js/views/page/index.js

import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    // Specific logic here
    console.log('PageIndexView mounted');
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('PageIndexView unmounted');
  }
}