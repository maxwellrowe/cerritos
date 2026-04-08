(function () {
	function onReady(callback) {
		if (document.readyState === "loading") {
			document.addEventListener("DOMContentLoaded", callback);
			return;
		}

		callback();
	}

	function setBsAttr(element, oldName, newName) {
		var value = element.getAttribute(oldName);

		if (value && !element.hasAttribute(newName)) {
			element.setAttribute(newName, value);
		}
	}

	function normalizeDataAttributes(root) {
		var selector = [
			"[data-toggle]",
			"[data-target]",
			"[data-dismiss]",
			"[data-parent]",
			"[data-ride]",
			"[data-slide]",
			"[data-slide-to]"
		].join(",");

		root.querySelectorAll(selector).forEach(function (element) {
			setBsAttr(element, "data-target", "data-bs-target");
			setBsAttr(element, "data-dismiss", "data-bs-dismiss");
			setBsAttr(element, "data-parent", "data-bs-parent");
			setBsAttr(element, "data-ride", "data-bs-ride");
			setBsAttr(element, "data-slide", "data-bs-slide");
			setBsAttr(element, "data-slide-to", "data-bs-slide-to");

			if (element.hasAttribute("data-toggle") && !element.hasAttribute("data-bs-toggle")) {
				element.setAttribute("data-bs-toggle", element.getAttribute("data-toggle"));
			}
		});

		root.querySelectorAll(".dropdown-toggle:not([data-bs-toggle])").forEach(function (element) {
			element.setAttribute("data-bs-toggle", "dropdown");
		});

		root.querySelectorAll(".navbar-toggle").forEach(function (element) {
			if (!element.hasAttribute("data-bs-toggle")) {
				element.setAttribute("data-bs-toggle", "collapse");
			}

			if (!element.hasAttribute("data-bs-target")) {
				if (element.hasAttribute("data-target")) {
					element.setAttribute("data-bs-target", element.getAttribute("data-target"));
				} else if (element.getAttribute("href") && element.getAttribute("href").charAt(0) === "#") {
					element.setAttribute("data-bs-target", element.getAttribute("href"));
				}
			}
		});
	}

	function bridgePlugin(name, Constructor, defaultAction) {
		if (!window.jQuery || !window.bootstrap || !Constructor) {
			return;
		}

		window.jQuery.fn[name] = function (option) {
			return this.each(function () {
				var config = typeof option === "object" ? option : {};
				var instance = Constructor.getOrCreateInstance(this, config);

				if (typeof option === "string" && typeof instance[option] === "function") {
					instance[option]();
					return;
				}

				if (defaultAction && typeof instance[defaultAction] === "function") {
					instance[defaultAction]();
				}
			});
		};
	}

	function addNavbarFallback() {
		document.querySelectorAll(".navbar-toggle").forEach(function (toggle) {
			toggle.addEventListener("click", function (event) {
				var selector = toggle.getAttribute("data-bs-target") || toggle.getAttribute("data-target") || toggle.getAttribute("href");

				if (!selector || selector.charAt(0) !== "#") {
					return;
				}

				var target = document.querySelector(selector);

				if (!target) {
					return;
				}

				// If the target isn't a Bootstrap collapse, provide a light fallback.
				if (!target.classList.contains("collapse")) {
					event.preventDefault();
					target.classList.toggle("show");

					var expanded = toggle.getAttribute("aria-expanded") === "true";
					toggle.setAttribute("aria-expanded", expanded ? "false" : "true");
				}
			});
		});
	}

	onReady(function () {
		normalizeDataAttributes(document);
		addNavbarFallback();

		bridgePlugin("modal", window.bootstrap && window.bootstrap.Modal, "show");
		bridgePlugin("dropdown", window.bootstrap && window.bootstrap.Dropdown);
		bridgePlugin("collapse", window.bootstrap && window.bootstrap.Collapse);
		bridgePlugin("tab", window.bootstrap && window.bootstrap.Tab);
		bridgePlugin("tooltip", window.bootstrap && window.bootstrap.Tooltip);
		bridgePlugin("popover", window.bootstrap && window.bootstrap.Popover);
		bridgePlugin("carousel", window.bootstrap && window.bootstrap.Carousel);
	});
})();
