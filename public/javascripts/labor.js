$(document).ready( function() {
  $('body').delegate('ul.grouper > li.group_title', 'click', function(e) { 
    $(e.target).closest('.grouper li.group_title').next('li.group').slideToggle();
    $(e.target).closest('.grouper li.group_title').toggleClass('current');
  });
  
  $('body').delegate('li.add .label > a', 'click', function(e) {
    $(e.target).closest('li.add .label').hide();
    $(e.target).closest('li.add').find('form').slideToggle();
    
    return false;
  });
  
  $('body').delegate('li .edit', 'click', function(e) {
    $(e.target).closest('li').hide();
    $(e.target).closest('li').next('li.edit_form').show().find('input[type=text]').focus();
    
    return false;
  });
});