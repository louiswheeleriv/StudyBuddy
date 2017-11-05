$('#user_password').on('input', checkPassword);
$('#user_password_confirmation').on('input', checkPassword);

function checkPassword() {
	var pw = $('#user_password').val();
	var pw_confirm = $('#user_password_confirmation').val();
	$('#pw-match').toggle(pw == pw_confirm);
	$('#pw-no-match').toggle(pw != pw_confirm);
	$('#pw-min-length').toggle(pw.length < 6);
}

function testSms() {
	var msg = $('#msg-test-sms');
	$.ajax({
		url: '/test_sms',
		type: 'POST',
		data: JSON.stringify({
			'phone': $('#user_phone').val()
		}),
		success: function(response) {
			msg.css('color', '#00aa00');
			msg.text('Sent!');
		},
		error: function(response) {
			msg.css('color', '#ff0000');
			msg.text('Error: ' + response.responseJSON.error);
		}
	});
}
