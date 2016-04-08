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

    //var dateChanged = function (event) {
    //    $(event.target).nextAll("input[type=hidden]").val(event.date.format())
    //}
    //
    //$('.datetime-picker').datetimepicker({
    //    extraFormats: [moment.ISO_8601]
    //}).on('dp.change', dateChanged);


    /**
     * visits/new nested form management
     */
    /**
     * Insert content into DOM
     * @param anchor The content is to be inserted after a element referenced by the anchor selector
     * @param key_id String pattern to be replace in the content with a new element id
     * @param content Html template
     */
    var add_fields = function(anchor, key_id, content) {
        var new_id = new Date().getTime();
        var regexp = new RegExp(key_id, "g")
        $(anchor).append(content.replace(regexp, new_id));
    }

    var remove_fields = function(link, anchor) {
        $(link).prev("input[type=hidden]").val("1");
        $(link).closest(anchor).hide();
    }

    /**
     * Handle add new service item
     */
    $('.order-frame').on('click', '.mca-add-content', function(event) {
        add_fields($(event.target).data('anchor-id'), $(event.target).data('id-key'), $(event.target).data('content'))
        event.preventDefault();
        return false;
    })

    /**
     * Handle remove a service item.
     */
    $('.order-frame').on('click', '.mca-remove-content', function(event) {
        remove_fields(event.target, '.order-row');
        event.preventDefault();
        return false;
    })

    /**
     * Calculate prices
     */
    var getOrderRow = function(element) {
        return $(element).closest('.order-row')
    }

    var getAmount = function(row) {
        return row.find('input[data-id="amount"]')
    }

    var getCost = function(row) {
        return row.find('input[data-id="cost"]')
    }

    var getTime = function(row) {
        return row.find('input[data-id="time"]')
    }

    var getPrice = function(row) {
        return row.find('input[data-id="price"]')
    }

    var getPriceVat = function(row) {
        return row.find('input[data-id="price_vat"]')
    }

    var updatePrice = function(row) {
        var price = getAmount(row).val()*getCost(row).val()*getTime(row).val()
        var priceVat = Math.ceil(price * 1.2 * 100) / 100
        getPrice(row).val(price)
        getPriceVat(row).val(priceVat)
    }

    $('.order-frame').on('change', '.mca-select-service', function(event) {
        var option = event.target.options[event.target.selectedIndex]
        var baseCost = $(option).data('base-cost')
        var baseTime = $(option).data('base-time')

        var row = getOrderRow(event.target)
        getCost(row).val(baseCost)
        getTime(row).val(baseTime)
        updatePrice(row);
    });

    $('.order-frame').on('change', 'input[data-id="amount"]', function(event) {
        var row = getOrderRow(event.target)
        updatePrice(row);
    })

    $('.order-frame').on('change', 'input[data-id="cost"]', function(event) {
        var row = getOrderRow(event.target)
        updatePrice(row);
    })

    $('.order-frame').on('change', 'input[data-id="time"]', function(event) {
        var row = getOrderRow(event.target)
        updatePrice(row);
    })
})
