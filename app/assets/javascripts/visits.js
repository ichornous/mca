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

    var add_fields = function(link, key_id, content) {
        console.log('add fields: ' + link + ' ' + key_id + ' ' + content)
        var new_id = new Date().getTime();
        var regexp = new RegExp(key_id, "g")
        $(link).parent().before(content.replace(regexp, new_id));
    }

    $('.mca-add-content').on('click', function(event) {
        add_fields(event.target, $(event.target).data('id-key'), $(event.target).data('content'))
        return false;
    })
})
