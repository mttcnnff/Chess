// web/static/js/views/loader.js

import MainView    from './main';
import PageNewView from './page/new';
import UserNewView from './user/new';
import PageIndexView from './page/index';
import PageHomeView from './page/home';

// Collection of specific view modules
const views = {
  PageNewView,
  UserNewView,
  PageIndexView,
  PageHomeView,
};

export default function loadView(viewName) {
	console.log(views[viewName]);
  	return views[viewName] || MainView;
}