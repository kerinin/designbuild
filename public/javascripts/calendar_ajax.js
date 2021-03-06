var active_project, active_request, resource_id, qv_id;

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
  //e.stopImmediatePropagation();
}

function handle_day(e) {
  var dayElem = $(e.target).closest('.day');
  var day = dayElem.attr('id');
  
  //$('.day').not('.day:has(.allocation)')
  if( !dayElem.hasClass('free') ) {
    
  } else if(active_project && active_request) {
    // Create the new resource allocation
    $('#new_resource_allocation input#resource_allocation_resource_request_id').val(active_request);
    $('#new_resource_allocation input#resource_allocation_start_date').val(day);
    $('form#new_resource_allocation').first().submit();
  
    // Update the display
    var content = $('#'+active_project+' .insertion_content').clone().first();
    dayElem.find('.date_text').before( content.removeClass("insertion_content") );
    
    refresh_view();
    // refresh_behavior();  // Needed because we've inserted new nodes to the DOM
  }  
}

function handle_delete(e) {
  var dayElem = $(e.target).closest('.day');
  $(e.target).closest('.allocation').each(function() {
    if ($(this).data("qtip")) $(this).qtip("destroy");
  });
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

function handle_allocation_drop(e, ui) {
  var targetDay = $(e.target).closest('.day');
  var dragged = ui.draggable;
  var newDay = targetDay.attr('id');
  
  targetDay.prepend( dragged );
  
  // AJAX for changes...
  dragged.find('form input#resource_allocation_start_date').val(newDay);
  dragged.find('form').first().submit();
  
  dragged.draggable('disable');
}
function handle_allocation_drag_start(e, ui) {
  $(e.target).closest('.day').addClass('free');
  
  // Setup drop targets
  $(".day.free").droppable({
    tolerance: 'pointer',
    hoverClass: 'drop_hover',
    activeClass: 'drop_active',
    drop: handle_allocation_drop
  });

  // Hide & Disable qtips
  $('.allocation').each(function() {
    if ($(this).data("qtip")) $(this).qtip("disable").qtip("hide");
  });
}
function handle_allocation_drag_stop(e, ui) {
  // Remove the droppable handler (initialized on each drag start)
  $(".day.free").droppable('destroy');
  
  $(this).css('left', 0).css('top',0).closest('.day').removeClass('free');
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

  // Switch off allocations for non-current resources (for quickview)
  if( qv_id != null ){
    $('.allocation').not('resource_'+qv_id).not('.insertion_content').removeClass('visible');
    $('.allocation.resource_'+qv_id).not('.insertion_content').addClass('visible');
  } else {
    $('.allocation').not('resource_'+resource_id).not('.insertion_content').removeClass('visible');
    $('.allocation.resource_'+resource_id).not('.insertion_content').addClass('visible');
  }
  
  $('.day').not('.day:has(.allocation.visible)').addClass('free');
  $('.day').has('.allocation.visible').removeClass('free');
}

function refresh_behavior() {
  // Update Events
  $('.request').unbind('click').click( handle_request );
  
  $('.day').unbind('click').click( handle_day);
  
  $('.delete a').unbind('click').click( handle_delete);
  
  $('.quick_view .quick_view_item').unbind('hover').hover(handle_quickview_over, handle_quickview_out);
  
  $( ".day .allocation" ).draggable({
     start: handle_allocation_drag_start,
     //drag: function(event, ui) {},
     stop: handle_allocation_drag_stop
  }).draggable('enable');
}

$(document).ready( function() {
  resource_id = $('h1.resource').attr('id').split('_')[1]
  
  refresh_view();
  refresh_behavior();

  $('.weeks').animate({
      scrollTop: $(".today").offset().top - 310
  }, 1000);
})