(function() {
    var myApp = angular.module('mca', [
        'templates',
        'ngRoute',
        'ngResource',
        'controllers']);

    myApp.config([ '$routeProvider',
        function ($routeProvider) {
            $routeProvider
                .when('/', {
                    templateUrl: "index.html",
                    controller: 'InquiriesController'
                })
        }
    ]);

    angular.module('mca.controllers',[]);
})();
