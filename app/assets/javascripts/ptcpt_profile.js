var $originals = null;

$(document).ready(function() {
	$originals = serializeUserInfo();
});

$('#btn-save').on('click', function() {
	if (confirm('Are you sure?')) {
		saveChanges();
	}
});

function toggleSaveButton(isEnabled) {
	$('#btn-save').toggleClass('disabled', !isEnabled);
}

function saveChanges() {
	toggleSaveButton(false);
	$.ajax({
		url: '/profile/update',
		type: 'POST',
		contentType: 'application/json',
		data: JSON.stringify({
			updates: changedUserInfo()
		}),
		success: function(response) {

		},
		error: function(response) {
			renderErrors(response.responseJSON);
			toggleSaveButton(true);
		}
	});
}

function changedUserInfo() {
	var newData = serializeUserInfo();
	return Object.keys(newData).filter(function(key) {
		if (typeof newData[key] == 'object') {
			return !objectsEqual(newData[key], $originals[key]);
		} else {
			return newData[key] != $originals[key];
		}
	}).reduce(function(obj, key) {
		obj[key] = newData[key];
		return obj;
	}, {});
}

function serializeUserInfo() {
	return {
		'first_name': $('#user_first_name').val(),
		'last_name': $('#user_last_name').val(),
		'email': $('#user_email').val(),
		'current_password': $('#user_current_password').val(),
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

function renderErrors(errorJson) {
	$('#save-error').html(errorJson.error);
}
