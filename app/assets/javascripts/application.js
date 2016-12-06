// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

//   ____            __ _        _                 _
//  / ___|_ __ __ _ / _| |_     / \   ___ __ _  __| | ___ _ __ ___  _   _
// | |   | '__/ _` | |_| __|   / _ \ / __/ _` |/ _` |/ _ \ '_ ` _ \| | | |
// | |___| | | (_| |  _| |_   / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |
//  \____|_|  \__,_|_|  \__| /_/   \_\___\__,_|\__,_|\___|_| |_| |_|\__, |
//                                                                  |___/
//

document.addEventListener("turbolinks:load", function() {
    $(function () {
        $(document).foundation();
    });


    $('#subscribe').click(function () {
        var email = $('#email').val();
        $.ajax({
                url: '/subscribe',
                type: 'post',
                dataType: 'json',
                data: {email: email}
            })
            .done(function (data) {
                console.log(data.message);
                $('.subscribe').html('<strong>' + data.message + '</strong>');
            })
            .fail(function (data) {
                $('.subscribe').append('<strong>' + data.responseJSON.message + '</strong>');
            });
    });
});
