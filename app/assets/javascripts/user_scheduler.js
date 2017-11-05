function daySelected(elem) {
	if ($(elem).is(':checked')) {
		var day = $(elem).attr('class');
		var siblings = $(elem).closest('div.schedule').find('input[type="checkbox"].' + day);
		for (i = 0; i < siblings.length; i++) {
			$(siblings[i]).prop('checked', false);
		}
		$(elem).prop('checked', true);
	}
}

function removeTime(elem) {
	$(elem).closest('div.schedule-row').remove();
}

function insertAtIndex(parent, index, item) {
	if (index === 0) {
		parent.prepend(item);
	} else {
		parent.children('div.row:nth-child('+(index + 1)+')').after(item);
	}
}
