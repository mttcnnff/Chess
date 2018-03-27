// web/static/js/views/loader.js

import MainView    from './main';
import PageNewView from './page/new';
import UserNewView from './user/new';
import PageIndexView from './page/index';
import PageHomeView from './page/home';
import PageGameView from './page/game';

// Collection of specific view modules
const views = {
  PageNewView,
  UserNewView,
  PageIndexView,
  PageHomeView,
  PageGameView,
};

export default function loadView(viewName) {
  	return views[viewName] || MainView;
}