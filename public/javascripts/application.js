// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Event.observe(window, 'load', function() {
    //To manage focus also on IE
    $$("input, textarea").each(function(input) {
        if (input.type == 'textarea' || input.type == 'text' || input.type == 'password') {
            input.onfocus = function() {this.addClassName('focused');}
            input.onblur = function() {this.removeClassName('focused');}
        }
    });
});