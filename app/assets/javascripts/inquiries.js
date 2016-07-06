(function() {
    var myAppControllers = angular.module('mca.controllers');

    myAppControllers.controller("InquiriesController", [ '$scope', '$routeParams', '$location', '$resource',
        function ($scope, $routeParams, $location, $resource) {
            $scope.search = function (keywords) {
                $location.path("/").search('keywords', keywords)
            };

            var Inquiry = $resource('/api/v1/workshops/:workshopId/inquiries/:inquiryId.:format', {
                clientId: '@id',
                workshopId: $scope.userInfo.workshop_id,
                format: 'json'
            });

            if ($routeParams.keywords) {
                var keywords = $routeParams.keywords.toLowerCase();
                Inquiry.query({
                        name: $routeParams.keywords
                    },
                    function (results) {
                        $scope.recipes = results;
                    });
            } else {
                $scope.recipes = []
            }
        }
    ]);
})();

