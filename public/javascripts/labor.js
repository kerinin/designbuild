$(document).ready( function() {
  $('ul.grouper > li').click(function(e){
    $('.grouper > li').removeClass('current');
    $(e.target).closest('.grouper li').addClass('current');
  })
})