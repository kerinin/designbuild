var active_project, active_request, qv_id;

function handle_request(e) {
  var requestElem = $(e.target).closest('.request');
  
  if( requestElem.hasClass('active') ) {
    active_request = null;
    active_project = null;    
  } else {
    active_request = $(e.target).closest('[id]').attr('id').split('_')[1];
    active_project = $(e.target).closest('.project').attr('id');    
  }

  refresh_view();  
}

function handle_day(e) {
  var dayElem = $(e.target).closest('.day');
  var day = dayElem.attr('id');
  
  //$('.day').not('.day:has(.allocation)')
  if( dayElem.hasClass('busy') ) {
    
  } else if(active_project && active_request) {
    // Create the new resource allocation
    $('#new_resource_allocation input#resource_allocation_resource_request_id').val(active_request);
    $('#new_resource_allocation input#resource_allocation_start_date').val(day);
    $('#new_resource_allocation').submit();
  
    // Update the display
    var content = $('#'+active_project+' .insertion_content').clone().first();
    dayElem.find('.date_text').before( content.removeClass("insertion_content") );
    
    refresh_view();
    refresh_behavior();  // Needed because we've inserted new nodes to the DOM
  }  
}

function handle_delete(e) {
  var dayElem = $(e.target).closest('.day');
  //dayElem.removeClass('busy');
  $(e.target).closest('.allocation').remove();
  
  refresh_view();  
}

function handle_quickview_over(e) {
  qv_id = $(e.target).closest('[id]').attr('id').split('_')[3];
  
  refresh_view();  
}
function handle_quickview_out(e) {
  qv_id = null;
  
  refresh_view();  
}

function refresh_view() {
  // Update Views
  if(active_request && qv_id == null){
    $('.day').addClass('active');
  } else {
    $('.day').removeClass('active');
  }
  $(".request").removeClass('active');
  $("#request_"+active_request).addClass('active');
  $('.day').not('.day:has(.allocation)').removeClass('busy');
  $('.day').has('.allocation').addClass('busy');
}

function refresh_behavior() {
  // Update Events
  $('.request').click( handle_request );
  
  $('.day').click( handle_day);
  
  $('.delete a').click( handle_delete);
  
  $('.quick_view .quick_view_item').hover(handle_quickview_over, handle_quickview_out);
}

$(document).ready( function() {
  refresh_view();
  refresh_behavior();

  $('.weeks').animate({
      scrollTop: $(".today").offset().top - 310
  }, 1000);
})