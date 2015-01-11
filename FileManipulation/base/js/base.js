var baseApp = angular.module('baseApp',[]);

var baseCtrl = baseApp.controller('baseCtrl',function($scope){

    $scope.items = [
		{'value':13,'name':'Soda',img:'img/soda.png'}
		,{'value':55,'name':'Hamburger',img:'img/hamburger.png'}
		,{'value':13,'name':'Coffe',img:'img/coffe.png'}
		,{'value':21,'name':'Muffin',img:'img/muffin.png'}
		,{'value':8,'name':'French Fries',img:'img/frenchFries.png'}
	];

});
