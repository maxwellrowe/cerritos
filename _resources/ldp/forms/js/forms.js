$(document).ready(function () {
// 8-19-22 Recommended update to next two lines due to issue with LDP forms. See Modern Campus ticket #108069.
// 	$('input:checkbox').attr('title', $('input:checkbox').attr('title').replace(/&quot;/g,'"'));
// 	$('input:checkbox').val($('input:checkbox').val().replace(/&quot;/g,'"'));
// 	if ($('input:checkbox').val() != null){
//         $('input:checkbox').attr('title', $('input:checkbox').attr('title').replace(/&quot;/g,'"'));
//         $('input:checkbox').val($('input:checkbox').val().replace(/&quot;/g,'"'));
//     }
	
	if($('input:checkbox') != null){
		$('input:checkbox').each(function(){
			$(this).attr('title',$(this).attr('title').replace(/&quot;/g,'"'));
			$(this).val($(this).val().replace(/&quot;/g,'"'));
		});
	}

	$(".ou-form [type='submit']").off('click').on('click', function () {
		var f_element = $(this);
		var bid = f_element.attr("id");
		var toRemove = 'btn_';
		var skid = bid.replace(toRemove, '');
		var form_data = $("#forms_" + skid).serialize();

		$("#form_" + skid).off('submit').on('submit', function (e) {
			e.preventDefault();
			$("#btn_"+skid).hide();

			$("#form_" + skid).append("<span id='spin'> <img src='{{f:80147724}}' height='50' width='50'></img> Submitting, Please Wait .. </span>");

			// disable submit while waiting for server response, to prevent multiple submissions
			$("#btn_"+skid).hide();
			$("#clr_"+skid).hide();

			$("#form_" + skid + ".label-danger").remove();

			if ($("#form_" + skid + " #hp"+ skid ).val().length > 0) {

			} else {

				$.ajax({
					type: "POST",
					cache: false,
					url: "/_resources/ldp/forms/php/forms.php", //form-submit.ashx
					data: $(this).serialize(),
					success: function (data) {
						var resultObj = jQuery.parseJSON(data);
						var errC = /[faultcode]+\s:/;
						var faultCode = errC.exec(resultObj.message);
						
						if (resultObj.active == false) {
							// remove the error elements so we can reset errors according to the new validation
							$("#form_" + skid + " .has-error").each(function(){
								$(this).removeClass("has-error");
								$(".label-danger", this).remove();
							});
							
							if (! this.faultCode) {
								$("#status_" + skid).addClass("alert alert-danger");
								var dataSet = resultObj.message + "<br/>";
								$.each(resultObj.data, function (i, data) {
									var d = data.message;
									var $group = $("#" + data.name);
									$group.addClass("has-error");
									var errorHTML = '<span style="margin-left:8px;" class="label label-danger" id="' + data.name + 'Error">' + data.message + '</span>';
									if ($('#' + data.name + 'Error').length == 0) {
										$("#" + data.name + " .control-label").append(errorHTML);
									}

									// focus and scroll to the first error element
									if (i === 0) {
										// $(window).scrollTop($group.offset().top);
										scrollToMiddle($group);
										$("#id_" + data.name).focus();
									}
								});
								$("#status_" + skid).html(dataSet);

								// re-enable submit button, so that user may fix errors and try again

								$("#btn_"+skid).show();
								$("#spin").remove();
							} else {
								var dataSet = resultObj.message + " " + resultObj.data[0].message;
								$("#status_" + skid).addClass("alert alert-danger");
								$("#status_" + skid).html(dataSet);
								// $(window).scrollTop($("#status_" + skid).offset().top);
								scrollToMiddle($("#status_" + skid));

							}
						} else {
							if(typeof redirectPath != 'undefined' && redirectPath != ''){ //check if there is a url to redirect to when the form is submitted
								window.location.href = redirectPath;
							}else{
								$("#status_" + skid).removeClass("alert alert-danger");
								$("#status_" + skid).addClass("alert alert-success");

								$("#form_" + skid).remove();
								$("#status_" + skid).html(resultObj.message);
								// $(document).scrollTop($("#status_" + skid).offset().top);
								scrollToMiddle($("#status_" + skid));
							}
						}
					},
					error: function (data) {
					}
				});
				return false;
			}
		});
	});

	//	date/time picker configs

	if(typeof OUC !== "undefined" && typeof OUC.dateTimePickers !== "undefined"){

		$.datetimepicker.setLocale('en');

		$(OUC.dateTimePickers).each(function(index, options){

			if(options.format == "datetime"){
				$(options.id).datetimepicker({
										value: options.default,
										format: 'm/d/y g:i A',
										formatTime: 'g:i A',
										step: 15
									});
			}
			else if(options.format == "date"){
				$(options.id).datetimepicker({
										value: options.default,
										timepicker:false,
										format:'m/d/Y',
										step: 15
									});
			}
			else if(options.format == "time"){
				$(options.id).datetimepicker({
										value: options.default,
										datepicker:false,
										format:'g:i A',
										formatTime: 'g:i A',
										step: 15
									});
			}
		});
	}
	
	scrollToMiddle = function(elem){
		var top = elem.offset().top;
		var speed = 700;
		var elOffset = elem.offset().top;
		var elHeight = elem.height();
		var winHeight = $(window).height();
		var offset;

		if (elHeight < winHeight) {
			offset = elOffset - ((winHeight / 2) - (elHeight / 2));
		}else{
			offset = elOffset;
		}
		
  		$('html, body').animate({scrollTop:offset}, speed);
	};


});
