
;(function(window) {

	var menu;

	var toggleMenu = function() {
		console.log('toggle');
		if (menu) {
			menu.classList.toggle('visible');
		}
	};

	window.onload = function() {
		menu = document.querySelectorAll('.menu-items')[0];
		menu.addEventListener('click', toggleMenu, false);
	};

})(window);


