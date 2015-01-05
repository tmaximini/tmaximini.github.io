
;(function(window) {

	var menu,
			burger;

	var toggleMenu = function() {
		if (menu) {
			menu.classList.toggle('visible');
			burger.classList.toggle('close');
		}
	};

	window.onload = function() {
		menu = document.querySelectorAll('.menu-items')[0];
		burger = document.querySelectorAll('.menu-icon')[0];
		burger.addEventListener('click', toggleMenu, false);
	};

})(this);


