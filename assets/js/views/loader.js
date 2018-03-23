// web/static/js/views/loader.js

import MainView    from './main';
import PageNewView from './page/new';
import UserNewView from './user/new';
import PageIndexView from './page/index';

// Collection of specific view modules
const views = {
  PageNewView,
  UserNewView,
  PageIndexView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}