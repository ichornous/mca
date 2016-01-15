# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
  console.log('ready')
  $("#calendar").fullCalendar(
    events: '/events.json',
    selectable: true,
    editable: true,
    selectHelper: true,
    select: (start, end, jsEvent, view, resource) ->
      console.log(start.format('YYYY-MM-DD'))
    eventDragStop: (event, jsEvent, ui, view) ->
      console.log(event)
  )
$(document).ready(ready)
$(document).on('page:load', ready)