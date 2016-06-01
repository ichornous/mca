$(document).on('ready page:load', function() {
    var calendarContainer = $("#calendar");
    var cursorDate = calendarContainer.data('cursor-date');
    var locale = $('#calendar').data('locale');
    calendarContainer.fullCalendar({
        events: '/visits.json',
        lang: locale,
        selectable: true,
        editable: true,
        selectHelper: true,
        defaultDate: cursorDate,
        defaultView: 'basicWeek',
        customButtons: {
            selectWorkshop: {
                text: I18n.visits.index.btn_create_visit,
                click: function() {
                    window.location='/visits/new';
                }
            }
        },
        header: {
            right: 'today selectWorkshop,prev,next'
        },

        /**
         * Triggered when a new date-range is rendered, or when the view type switches.
         * @param view View Object
         * @param element jQuery object for the new view
         */
        viewRender: function(view, element) {
            var dateStr = view.calendar.getDate().format('YYYY-MM-DD');
            calendarContainer.data('cursor-date', dateStr);

            var state = history.state;
            if (!state)
                return;
            state.url = window.location.pathname + '?day=' + dateStr;
            window.history.replaceState(state, '', state.url);
        },

        /**
         * Render event in the calendar
         * @param event Calendar event object
         * @param element DOM elemenet which represents the event
         */
        eventRender: function(event, element) {
            var newDescription =
                    /*moment(event.start).format("HH:mm") + '-'
                    + moment(event.end).format("HH:mm") + '<br/>' + */
                '<strong>' + (event.car_name? event.car_name : event.client_name) + '</strong> ' + event.services.join('+')
                ;
            var elContent = element.find(".fc-content");
            elContent.empty();
            elContent.append(newDescription);
        }
    });

    $('#mca-timeslot-range').datepicker({
        language: $('#mca-timeslot-range').data('locale')
    });

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
        var regexp = new RegExp(key_id, "g");
        $(anchor).append(content.replace(regexp, new_id));
    };

    var remove_fields = function(link, anchor) {
        $(link).prev("input[type=hidden]").val("1");
        $(link).closest(anchor).hide();

        updateTotalPrice();
        updateTotalTime();
    };

    /**
     * Handle add new service item
     */
    $('.order-frame').on('click', '.mca-add-content', function(event) {
        add_fields($(event.target).data('anchor-id'), $(event.target).data('id-key'), $(event.target).data('content'))
        event.preventDefault();
        return false;
    });

    /**
     * Handle remove a service item.
     */
    $('.order-frame').on('click', '.mca-remove-content', function(event) {
        remove_fields(event.target, '.order-row');
        event.preventDefault();
        return false;
    });

    /**
     * Calculate prices
     */
    var getOrderRow = function(element) {
        return $(element).closest('.order-row')
    };

    var getAmount = function(row) {
        return row.find('input[data-id="amount"]')
    };

    var getCost = function(row) {
        return row.find('input[data-id="cost"]')
    };

    var getTime = function(row) {
        return row.find('input[data-id="time"]')
    };

    var getPrice = function(row) {
        return row.find('input[data-id="price"]')
    };

    var getPriceVat = function(row) {
        return row.find('input[data-id="price_vat"]')
    };

    var safeToFloat = function(str) {
        if (str != "" && !isNaN(str))
            return parseFloat(str);
        return 0;
    };

    var updateTotalPrice = function() {
        var totalPrice = 0;
        $('input[data-id="price"]:visible').each(function() {
            totalPrice = totalPrice + safeToFloat($(this).val());
        });
        $('#total_price').val(Math.ceil(totalPrice * 100) / 100);
    };

    var updateTotalTime = function() {
        var totalTime = 0;
        $('input[data-id="time"]:visible').each(function() {
            totalTime = totalTime + safeToFloat($(this).val());
        });
        $('#total_time').val(Math.ceil(totalTime * 100) / 100);
    };

    var updatePrice = function(row) {
        var price = getAmount(row).val()*getCost(row).val();
        var priceVat = Math.ceil(price * 1.2 * 100) / 100;

        getPrice(row).val(price);
        getPriceVat(row).val(priceVat);

        updateTotalPrice();
        updateTotalTime();
    };

    var setDefaults = function(row) {
        var target = row.find('.mca-select-service').get(0);
        var option = target.options[target.selectedIndex];
        var baseCost = $(option).data('base-cost');
        var baseTime = $(option).data('base-time');

        var row = getOrderRow(target);
        getCost(row).val(baseCost);
        getTime(row).val(baseTime);
    };

    $('.order-frame').on('change', '.mca-select-service', function(event) {
        var row = getOrderRow(event.target);
        setDefaults(row);
        updatePrice(row);
    });

    $('.order-frame').on('change', 'input[data-id="amount"]', function(event) {
        var row = getOrderRow(event.target);
        updatePrice(row);
    });

    $('.order-frame').on('change', 'input[data-id="cost"]', function(event) {
        var row = getOrderRow(event.target);
        updatePrice(row);
    });

    $('.order-frame').on('change', 'input[data-id="time"]', function(event) {
        var row = getOrderRow(event.target);
        updatePrice(row);
    });

    $('tbody > .order-row').each(function() {
        setDefaults($(this));
        updatePrice($(this));
    });

    $('.mca-select-color').simplecolorpicker({
        theme: 'glyphicons'
    });
});