$(document).ready(function() {
	if ($('#select-study').val() == 'admin') {
		toggleAdmin(true);
	}
});

$('#select-study').on('change', function() {
	var selectedStudyId = $(this).val();
	if (selectedStudyId == 'admin') {
		toggleAdmin(true);
	} else {
		toggleAdmin(false);
		$.ajax({
			url: '/admin/signup/load_study_phases?study=' + selectedStudyId,
			type: 'GET',
			success: function(response) {
				$('#study-start').text(response.study.start_date);
				$('#study-end').text(response.study.end_date);
				$('#phase-edit').html(response.phase_edit);
			},
			error: function(response) {
				console.log(response);
			}
		});
	}
});

function toggleAdmin(isAdmin) {
	$('#section-schedule').toggle(!isAdmin);
	$('#section-phase-dates').toggle(!isAdmin);
	$('#msg-select-study').toggle(!isAdmin);
}

function submitSignUp() {
	toggleSignUpButton(false);
	$.ajax({
		url: '/admin/signup',
		type: 'POST',
		contentType: 'application/json',
		data: JSON.stringify({
			study_id: $('#select-study').val(),
			user: serializeUserInfo(),
			schedule: serializeScheduleInfo(),
			phase_dates: serializePhaseDateInfo()
		}),
		success: function(response) {
			// user redirected to /admin/signup/info
		},
		error: function(response) {
			renderErrors(response.responseJSON);

			// err = response.responseJSON.error;
			// loc = response.responseJSON.location;
			// if (loc) {
			// 	$(loc).text(err);
			// }
			toggleSignUpButton(true);
		}
	});
}

function toggleSignUpButton(clickable) {
	$('#btn-sign-up').toggle(clickable);
	$('#btn-sign-up-disabled').toggle(!clickable);
}

function serializeUserInfo() {
	return {
		'first_name': $('#user_first_name').val(),
		'last_name': $('#user_last_name').val(),
		'participant_number': $('#user_participant_number').val(),
		'email': $('#user_email').val(),
		'password': $('#user_password').val(),
		'password_confirmation': $('#user_password_confirmation').val(),
		'phone': $('#user_phone').val(),
		'timezone': serializeTimeZoneInfo()
	}
}

function serializeTimeZoneInfo() {
	var selectedTZ = $('option:selected', $('select.timezone'));
	return {
		'name': selectedTZ[0].innerText,
		'gmtOffset': selectedTZ.val(),
		'usesDST': selectedTZ.attr('useDaylightTime')
	}
}

function serializeScheduleInfo() {
	var wakeRows = $('div.schedule-wake > div.schedule-row');
	var sleepRows = $('div.schedule-sleep > div.schedule-row');
	return {
		'wake': readScheduleTimes(wakeRows),
		'sleep': readScheduleTimes(sleepRows)
	};
}

function readScheduleTimes(rows) {
	result = {};
	for (var i = 0; i < rows.length; i++) {
		var time = (
			$(rows[i]).find('select.hour')[0].value + ':' +
			$(rows[i]).find('select.minute')[0].value
		);
		var daySelections = $(rows[i]).find('div.col-day > input[type="checkbox"]');
		for (var j = 0; j < daySelections.length; j++) {
			if ($(daySelections[j]).is(':checked')) {
				var day = $(daySelections[j]).attr('class');
				result[day] = time;
			}
		}
	}
	return result;
}

function serializePhaseDateInfo() {
	return $('div.user-phase-edit div.input-daterange input.datepicker').map(function() {
		var phaseClass = findClassMatchingRegex($(this).closest('div.phase'), /^phase-\d+$/);
		var phaseId = Number(phaseClass.split('-')[1])
		return {
			'phaseId': phaseId,
			'startEndType': $(this).attr('name'),
			'date': $(this).datepicker('getDate')
		}
	}).toArray();
}

function findClassMatchingRegex(elem, regex) {
	return elem.attr('class').split(' ').find(function(cls) {
		return regex.test(cls);
	});
}

function renderErrors(errors) {
	hideErrors();
	var msgsByLocation = {
		'#msg-bottom': 'Errors while saving, see info in red.'
	};
	for (var i = 0; i < errors.length; i++) {
		var err = errors[i];
		if (err.location) {
			if (msgsByLocation[err.location]) {
				msgsByLocation[err.location] = (msgsByLocation[err.location] + '<br/>' + err.error);
			} else {
				msgsByLocation[err.location] = err.error;
			}
		}
	}
	for (var location in msgsByLocation) {
		if (msgsByLocation.hasOwnProperty(location)) {
			$(location).html(msgsByLocation[location]);
			$(location).show();
    }
	}
}

function hideErrors() {
	$('.err').text('');
	$('.err').hide();
}
