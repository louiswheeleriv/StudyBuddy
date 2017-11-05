$(document).ready(function() {

	function initDatePickers() {
		$('div.input-daterange').datepicker({
			format: 'yyyy/mm/dd'
			// TODO: provide startDate and endDate here based on study dates
		}).on('changeDate', function(e) {
			// TODO: Update date restrictions based on selected date.
			// we have access here to e.date which returns date object
		});
	}

	initDatePickers();
});
