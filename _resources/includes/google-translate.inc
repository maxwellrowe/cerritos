<div id="google_translate_element"></div>
<script type="text/javascript">
// <![CDATA[
function googleTranslateElementInit() {
    new google.translate.TranslateElement(
        {
            pageLanguage: 'en',
            layout: google.translate.TranslateElement.InlineLayout.VERTICAL,
            autoDisplay: false
        },
        'google_translate_element'
    );

    var $googleDiv = $("#google_translate_element .skiptranslate");
    var $googleDivChild = $("#google_translate_element .skiptranslate div");

    $googleDivChild.next().remove();

    $googleDiv.contents().filter(function () {
        return this.nodeType === 3 && $.trim(this.nodeValue) !== '';
    }).remove();
}
// ]]>
</script>
<noscript>Your browser does not support JavaScript!</noscript>
<script
    type="text/javascript"
    src="https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"
></script>
<noscript>Your browser does not support JavaScript!</noscript>
