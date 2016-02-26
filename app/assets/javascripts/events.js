$(document).on('ready page:load', function() {
  console.log('ready')
  $("#calendar").fullCalendar({
      events: '/events.json',
      selectable: true,
      editable: true,
      selectHelper: true,
      defaultView: 'basicWeek',
      select: function (start, end, jsEvent, view, resource) {
          console.log(start.format('YYYY-MM-DD'))
      },
      eventDragStop: function (event, jsEvent, ui, view) {
          console.log(event)
      }
  })

  var dateChanged = function (event) {
      console.log($(event.target).nextAll("input[type=hidden]"))
      $(event.target).nextAll("input[type=hidden]").val(event.date.unix())
  }

  $('.datetimepicker').datetimepicker()
    .on('dp.change', dateChanged);
})