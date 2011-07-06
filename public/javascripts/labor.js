$(document).ready( function() {
  $('ul.grouper > li.group_title').click(function(e){
    $(e.target).closest('.grouper li.group_title').next('li.group').slideToggle();
    $(e.target).closest('.grouper li.group_title').toggleClass('current');
  })
})