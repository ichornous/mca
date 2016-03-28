$(document).on('ready page:load', function() {
    $("#calendar").fullCalendar({
        events: '/visits.json',
        selectable: true,
        editable: true,
        selectHelper: true,
        defaultView: 'basicWeek',
        customButtons: {
            selectWorkshop: {
                text: 'New Event',
                click: function() {
                    window.location='visits/new';
                }
            }
        },
        header: {
            right: 'selectWorkshop today prev,next'
        },
        select: function (start, end, jsEvent, view, resource) {
            console.log(start.format('YYYY-MM-DD'))
        },
        eventDragStop: function (event, jsEvent, ui, view) {
            console.log(event)
        }
    })

    var dateChanged = function (event) {
        $(event.target).nextAll("input[type=hidden]").val(event.date.format())
    }

    $('.datetimepicker').datetimepicker()
        .on('dp.change', dateChanged);
})