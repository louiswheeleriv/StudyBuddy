// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require bootstrap-datepicker

function objectsEqual(obj1, obj2) {
	return Object.keys(obj1).every(function(key) {
		return obj1[key] == obj2[key];
	}) &&
	Object.keys(obj2).every(function(key) {
		return obj2[key] == obj1[key];
	})
}
