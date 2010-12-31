// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var t;

$(document).ready( function() {

  $('.add_component').bind('ajax:success', function() {  
    $(this).closest('tr').fadeOut();  
  });
  
  $('.expander .activator').click( function(e) {
    $(this).closest('.expander').toggleClass('expanded');
  });
  
  $('.expander .activator').mouseenter( function(e) {
    $('.expander').not($(this).closest('.expander')).removeClass('expanded');
  });
  
  $('.expander .activator').mouseleave( function(e) {
    if( !$(this).closest('.expander').hasClass('expanded') ) {
      $(this).closest('.expander').addClass('expanded');
      clearTimeout(t);
      t=setTimeout(function(thisObj){ $(thisObj).closest('.expander').removeClass('expanded')}, 300, this);
    }
  });
  
  $('.tabs').tabs();
});
