function formHandler() {
    var destination = document.KeyWordSearch.site.options[
        document.KeyWordSearch.site.selectedIndex
    ].value;

    window.location.href = destination;
}

function js_PopUpWindow(width, height, url) {
    alert("Warning: This link will open a popup window. Please adjust your browser settings to allow popups.");

    var settings = "width=" + width + ",height=" + height + ",resizable=yes,status=yes,scrollbars=no";
    settings += "left=10,";
    settings += "top=10";

    newWindow = window.open(url, "PopUpWindow", settings);
}

function popupWarning(url) {
    if (
        confirm(
            "Warning: This link will open a popup window for an offsite URL.  Please adjust your browser settings to allow popups.\nSelect 'OK' to open a new window or select 'Cancel' to navigate without a popup."
        ) === true
    ) {
        window.open(url);
    } else {
        window.location.href = url;
    }
}

function photo_detail(src, alt) {
    window.location.href = "/scripts/photo_detail.asp?src=" + src + "&alt=" + alt;
}

function popupWarning_subscribe(url) {
    if (
        confirm(
            "Warning: This link will open a popup window.  Please adjust your browser settings to allow popups.\nDo you want to continue?  Select 'OK' to continue or select 'Cancel' to navigate without a popup."
        ) === true
    ) {
        window.open(url, "name", "height=275, width=350");
    } else {
        window.location.href = url;
    }
}

function popupWarning_offcampus(url) {
    if (
        confirm(
            "Warning: This link will open content located on another site not associated with Cerritos College. We cannot ensure accessibility of pages visited. Please adjust your browser settings to allow popups.\n\nDo you want to continue?"
        ) !== true
    ) {
        return false;
    }

    window.open(url, "_blank");
}

function popup_offcampus_simple(url) {
    if (
        confirm(
            "Warning: This link navigates away from Cerritos College. Please adjust your browser settings to allow popups."
        ) !== true
    ) {
        return false;
    }

    window.open(url);
}

function popupWarningEdit(url) {
    !window.opera && navigator.userAgent.indexOf(" OPR/");
    Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor");
    window.chrome;

    if (document.documentMode) {
        alert("Warning: OU Campus does not work with IE. Please use Google Chrome for best results.");
    } else {
        window.location.href = url;
    }
}

var RecaptchaOptions = {
    theme: "white"
};

$(document).ready(function () {
    $(".close-icon").click(function () {
        $("#emergencyNotice").hide(750);
        createCookie("hide", true, 1);
        return false;
    });

    if (readCookie("hide")) {
        $("#emergencyNotice").hide();
    } else {
        $("#emergencyNotice").show();
    }
});

$(document).ready(function () {
    $(".close-icon").click(function () {
        $("#emergencyNotice-2").hide(750);
        createCookie("hide-2", true, 1);
        return false;
    });

    if (readCookie("hide-2")) {
        $("#emergencyNotice-2").hide();
    } else {
        $("#emergencyNotice-2").show();
    }
});

$(document).ready(function () {
    $(".acceptcookies-2").click(function () {
        $("#CC_Alert-2").hide();
        createCookie("hide-modal", true, 1);
        $("body").removeClass("modal-open");
        $(".modal-backdrop").remove();
        return false;
    });

    if (readCookie("hide-modal")) {
        $("#CC_Alert-2").hide();
    } else {
        $("#CC_Alert-2").modal({
            backdrop: "static"
        });
    }
});

$(document).ready(function () {
    $(".acceptcookies-summer").click(function () {
        $("#CC_Alert-summer").hide();
        createCookie("hide-modal-summer", true, 1);
        $("body").removeClass("modal-open");
        $(".modal-backdrop").remove();
        return false;
    });

    if (readCookie("hide-modal-summer")) {
        $("#CC_Alert-summer").hide();
    } else {
        $("#CC_Alert-summer").modal({
            backdrop: "static"
        });
    }
});

var now = new Date();

function createCookie(name, value, days) {
    var expires;

    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + 1800000);
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }

    document.cookie = name + "=" + value + expires + "; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var cookies = document.cookie.split(";");

    for (var i = 0; i < cookies.length; i++) {
        var cookie = cookies[i];

        while (cookie.charAt(0) === " ") {
            cookie = cookie.substring(1, cookie.length);
        }

        if (cookie.indexOf(nameEQ) === 0) {
            return cookie.substring(nameEQ.length, cookie.length);
        }
    }

    return null;
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}

now.setTime(now.getTime() + 3600000);
document.cookie = "name=value; expires=" + now.toUTCString() + "; path=/";

/*!
  jQuery a11yExpandable plugin
  @name jquery.a11yExpandable.js
  @author Heydon (heydon@heydonworks.com or @heydonworks)
  @version 1.0
  @date 01/01/2013
  @category jQuery Plugin
  @copyright (c) 2015 (Heydon Pickering)
  @license Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
*/
$(document).ready(function () {
    var $ = jQuery;

    $.fn.a11yExpandable = function () {
        return this.each(function () {
            var trigger = $(this);

            trigger.attr({
                "aria-expanded": "false",
                "aria-controls": trigger.attr("data-expandable")
            });

            var target = $("#" + trigger.attr("data-expandable")).attr({
                "aria-hidden": "true",
                "class": "expandable"
            });

            trigger.on("click", function () {
                var expanded = $(this).attr("aria-expanded") !== "false";

                trigger.attr("aria-expanded", !expanded);
                target.attr("aria-hidden", expanded);
            });
        });
    };

    $("[data-expandable]").a11yExpandable();
});

$(function () {
    $("#hide_t_rows").hide();

    $("#btn1").click(function () {
        $(".buttonInactive").not(this).removeClass("buttonInactive");
        $(this).toggleClass("buttonActive");

        if ($(this).hasClass("buttonActive")) {
            $("#hide_t_rows").show();
            $("#btn1").html("Less Majors");
        } else {
            $("#hide_t_rows").hide();
            $("#btn1").html("More Majors");
        }
    });
});

$(window).load(function () {
    $(".search").on("shown.bs.dropdown", function () {
        var input = $(this).find("input:text").first();

        setTimeout(function () {
            input.focus();
        }, 100);
    });
});
