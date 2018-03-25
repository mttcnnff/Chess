// web/static/js/views/user/new.js

import MainView from '../main';
import * as Alerts from '../alerts';

export default class View extends MainView {
  mount() {
    super.mount();

    // Set up an event listener for the contact form.
    $('#new-user').submit(function(event) {
        // Stop the browser from submitting the form.
        event.preventDefault();

        const formData = $('#new-user').serialize();
        // Submit the form using AJAX.
        $.ajax({
            type: 'POST',
            url: $('#new-user').attr('action'),
            data: formData,
            success: (resp) => {Alerts.flashAlert("New user created!"); $('#new-user')[0].reset()},
            error: (resp) => {Alerts.flashDanger("Failed - " + resp.responseText)},
        })
    })

    // Specific logic here
    console.log('UserNewView mounted');
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('UserNewView unmounted');
  }
}