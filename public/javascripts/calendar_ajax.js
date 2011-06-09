var active_project, active_request;

function set_active_state() {
  if(active_request){
    $('.day').addClass('active');
  } else {
    $('.day').removeClass('active');
  }
  
  $(".request").removeClass('active');
  $("#request_"+active_request).addClass('active');
  
  $('.request').click( function(e){
    active_request = $(e.target).closest('[id]').attr('id').split('_')[1];
    active_project = $(e.target).closest('.project').attr('id');
    
    set_active_state();
  } );
  
  $('.request.active').click( function(e){
    active_request = null;
    active_project = null;
    
    set_active_state();
  })
  
  $('.day').click( function(e) {
    var dayElem = $(e.target).closest('.day');
    var day = dayElem.attr('id');
    
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
  
  $('.delete a').click( function(e) {
    var dayElem = $(e.target).closest('.day');
    dayElem.removeClass('busy');
    $(e.target).closest('.allocation').remove();
  } );
}

$(document).ready( function() {
  set_active_state();

  $('.weeks').animate({
      scrollTop: $(".today").offset().top - 310
  }, 1000);
})