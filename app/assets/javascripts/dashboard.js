var $questions = [];
var $selectedQuestionIndex = null;

$(document).ready(function() {
	$questions = JSON.parse($('.page-data').attr('data'));
	if ($questions.length == 0) {
		$('#no-questions').show();
	} else {
		$('#questions').show();
		$selectedQuestionIndex = 0;
		updateQuestionPanel();
	}
});

function prevQuestion() {
	$selectedQuestionIndex -= 1;
	updateQuestionPanel();
}

function nextQuestion() {
	$selectedQuestionIndex += 1;
	updateQuestionPanel();
}

function updateQuestionPanel() {
	$('#question-number').html($selectedQuestionIndex + 1);
	$('#question-total').html($questions.length);
	$('#question-title').html($questions[$selectedQuestionIndex].question_text);
	$('#question-inputs').html(buildQuestionInputsHtml());
	updatePrevNextBtns();
}

function buildQuestionInputsHtml() {
	var ans = $questions[$selectedQuestionIndex].answer_type
	if (['string', 'text'].includes(ans.type)) {
		return '<input type="text" class="form-control" placeholder="Answer here"/>';
	} else if (ans.type == 'number' && ans.range) {
		if (ans.type == 'number' &&
			ans.range.min &&
			ans.range.max) {
			var min = ans.range.min;
			var max = ans.range.max;
			return '<input type="number" class="form-control" min="'+min+'" max="'+max+'" placeholder="Range '+min+' to '+max+'"/>';
		}
	} else if (ans.type == 'number') {
		return '<input type="number" class="form-control" placeholder="Answer here"/>';
	} else if (ans.type == 'boolean') {
		return '<select class="form-control"><option value="true">Yes</option><option value="false">No</option></select>';
	} else if (ans.type == 'enum') {
		var html = '<select class="form-control">';
		ans.options.forEach(function(option) {
			html += '<option value="'+option+'">'+option+'</option>';
		});
		html += '</select>';
		return html + html + html;
	}
	debugger;
	return 'ERROR!';
}

function updatePrevNextBtns() {
	togglePrevBtn($selectedQuestionIndex > 0);
	toggleNextBtn($selectedQuestionIndex < ($questions.length - 1));
}

function togglePrevBtn(isEnabled) {
	$('#btn-prev-question').toggleClass('disabled', !isEnabled);
}

function toggleNextBtn(isEnabled) {
	$('#btn-next-question').toggleClass('disabled', !isEnabled);
}

function submitAnswer() {
	$.ajax({
		url: '/dashboard/answer',
		type: 'POST',
		contentType: 'application/json',
		data: JSON.stringify({
			user_datum_id: $questions[$selectedQuestionIndex].user_datum_id,
			answers: serializeAnswer()
		}),
		success: function(response) {
			$('#question-error').html('');
			removeAnsweredQuestion();
		},
		error: function(response) {
			$('#question-error').html(response.responseJSON.error);
		}
	});
}

function serializeAnswer() {
	return $('#question-inputs .form-control').toArray().map(function(input) {
		return $(input).val();
	});
}

function removeAnsweredQuestion() {
	$questions.splice($selectedQuestionIndex, 1);
	if ($questions.length < 1) {
		$('#questions').hide();
		$('#no-questions').show();
		$selectedQuestionIndex = null;
		return;
	} else if ($selectedQuestionIndex > ($questions.length - 1)) {
		$selectedQuestionIndex = ($questions.length - 1);
	}
	updateQuestionPanel();
}
