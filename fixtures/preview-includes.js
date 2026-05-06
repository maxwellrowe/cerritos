(function (window, document) {
    'use strict';

    function requestInclude(path) {
        var xhr = new XMLHttpRequest();

        xhr.open('GET', path, false);
        xhr.send(null);

        if (xhr.status >= 200 && xhr.status < 300) {
            return xhr.responseText;
        }

        throw new Error('Preview include failed: ' + path + ' (' + xhr.status + ')');
    }

    function resolveTarget(target) {
        if (typeof target === 'string') {
            return document.querySelector(target);
        }

        return target;
    }

    window.PreviewIncludes = {
        mount: function (target, path) {
            var element = resolveTarget(target);

            if (!element) {
                return;
            }

            try {
                element.innerHTML = requestInclude(path);
                element.setAttribute('data-preview-include-loaded', path);
            } catch (error) {
                console.error(error);
                element.setAttribute('data-preview-include-error', path);
            }
        }
    };
})(window, document);
