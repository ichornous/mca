receta = angular.module('receta',[
    'templates',
    'ngRoute',
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
controllers.controller("RecipesController", [ '$scope', '$routeParams', '$location',
    function ($scope, $routeParams, $location) {
        $scope.search = function (keywords) {
            $location.path("/").search('keywords', keywords)
        };

        if ($routeParams.keywords) {
            var keywords = $routeParams.keywords.toLowerCase();
            $scope.recipes = recipes.filter(function(recipe){ return recipe.name.toLowerCase().indexOf(keywords) != -1 })
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