var active_project, active_request;

$(document).ready( function() {
  //$('h2.project').wrap("<a href='#'");
  $('.request').click( function(e){
    active_request = $(e.target).closest('[id]').attr('id').split('_')[1];
    active_project = $(e.target).closest('.project').attr('id');
    
    $('.day').addClass('active')
  } );
  
  $('.day').click( function(e) {
    var day = $(e.target).attr('id')
    
    if(active_project && active_request) {
      // Create the new resource allocation
      $('#new_resource_allocation input#resource_allocation_resource_request_id').val(active_request);
      $('#new_resource_allocation input#resource_allocation_start_date').val(day);
      //$('#new_resource_allocation').submit();
      
      // Update the display
      var content = $('#'+active_project+' .insertion_content').clone().first();
      $(e.target).find('.date_text').before( content.removeClass("insertion_content") );
      $(e.target).addClass('busy')
    }
  } );
})