var active_project, active_request;

$(document).ready( function() {
  //$('h2.project').wrap("<a href='#'");
  $('.request').click( function(e){
    active_request = $(e.target).closest('[id]').attr('id').split('_')[1];
    active_project = $(e.target).closest('.project').attr('id');
    
    $('.day').addClass('active')
  } );
  
  $('.delete a').click( function(e) {
    var dayElem = $(e.target).closest('.day');
    dayElem.removeClass('busy');
    $(e.target).closest('.allocation').remove();
  })
  $('.day').click( function(e) {
    var dayElem = $(e.target).closest('.day')
    var day = dayElem.attr('id')
    
    if( dayElem.hasClass('busy') ) {
      
    } else if(active_project && active_request) {
        // Create the new resource allocation
        $('#new_resource_allocation input#resource_allocation_resource_request_id').val(active_request);
        $('#new_resource_allocation input#resource_allocation_start_date').val(day);
        $('#new_resource_allocation').submit();
      
        // Update the display
        var content = $('#'+active_project+' .insertion_content').clone().first();
        dayElem.find('.date_text').before( content.removeClass("insertion_content") );
        dayElem.addClass('busy')
      }
  } );
})