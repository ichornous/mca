receta = angular.module('receta',[
    'templates',
    'ngRoute',
    'ngResource',
    'controllers'
]);

receta.config([ '$routeProvider',
    function ($routeProvider) {
        $routeProvider
            .when('/', {
                templateUrl: "index.html",
                controller: 'RecipesController'
            })
    }
]);

controllers = angular.module('controllers',[]);
controllers.controller("RecipesController", [ '$scope', '$routeParams', '$location', '$resource',
    function ($scope, $routeParams, $location, $resource) {
        $scope.search = function (keywords) {
            $location.path("/").search('keywords', keywords)
        };

        var Client = $resource('/api/v1/workshops/:workshopId/clients/:clientId.:format', {
            clientId: '@id',
            workshopId: $scope.userInfo.workshop_id,
            format: 'json'
        });

        if ($routeParams.keywords) {
            var keywords = $routeParams.keywords.toLowerCase();
            Client.query({
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

recipes = [
    {
        id: 1,
        name: 'Baked Potato w/ Cheese'
    },
    {
        id: 2,
        name: 'Garlic Mashed Potatoes'
    },
    {
        id: 3,
        name: 'Potatoes Au Gratin'
    },
    {
        id: 4,
        name: 'Baked Brussel Sprouts'
    }
];