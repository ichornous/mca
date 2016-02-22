/**
 * Created by igor on 2/22/16.
 */
$(document).on('ready page:load', function() {
    $( ".connectedSortable" ).sortable({
        connectWith: ".connectedSortable"
    }).disableSelection();
});