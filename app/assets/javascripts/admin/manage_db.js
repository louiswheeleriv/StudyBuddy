var numRecordsToCreate = 0;
var recordIdsToUpdate = [];
var recordIdsToDelete = [];
var viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
var scrollDurationMillis = 600;

$('div#records-container tbody i.fa-pencil').on('click', function() {
	var row = $(this).closest('tr');

	// Show editable cells
	row.find('div.col-read').hide();
	row.find('div.col-edit').show();

	// Hide action icons, show cancel button
	$(this).hide();
	row.find('i.fa-trash').hide();
	row.find('span.cancel-edit').show();
	recordIdsToUpdate.push(Number(row.attr('data-id')));
	toggleSaveButton(true);
});

$('div#records-container tbody span.cancel-edit').on('click', function() {
	var row = $(this).closest('tr');

	// Reset values in col-edit inputs
	var cells = row.find('td.editable');
	for (var i = 0; i < cells.length; i++) {
		resetCell($(cells[i]));
	}

	// Hide inputs
	row.find('div.col-edit').hide();
	row.find('div.col-read').show();

	// Hide cancel button, show action icons
	$(this).hide();
	row.find('i.fa-pencil, i.fa-trash').show();
	recordIdsToUpdate = removeAllInstances(recordIdsToUpdate, Number(row.attr('data-id')));
	if (numRecordsToCreate < 1 &&
		recordIdsToUpdate.length < 1 &&
		recordIdsToDelete.length < 1) {
		toggleSaveButton(false);
	}
});

// Reset a cell to its value before editing
// Assuming cell is a td.editable
function resetCell(cell) {
	var read = cell.find('div.col-read > input');
	var edit = cell.find('div.col-edit > input');
	if (cell.find('input').attr('type') == 'checkbox') {
		edit.prop('checked', read.prop('checked'));
	} else {
		edit.val(read.val());
	}
}

$('div#records-container tbody i.fa-trash').on('click', function() {
	var row = $(this).closest('tr');

	// Mark row for deletion
	row.find('i.fa-pencil, i.fa-trash').hide();
	row.find('span.cancel-delete').show();
	recordIdsToDelete.push(Number(row.attr('data-id')));
	toggleSaveButton(true);
});

$('div#records-container tbody span.cancel-delete').on('click', function() {
	var row = $(this).closest('tr');

	// Un-mark row for deletion
	row.find('span.cancel-delete').hide();
	row.find('i.fa-pencil, i.fa-trash').show();
	recordIdsToDelete = removeAllInstances(recordIdsToDelete, Number(row.attr('data-id')));
	if (numRecordsToCreate < 1 &&
		recordIdsToUpdate.length < 1 &&
		recordIdsToDelete.length < 1) {
		toggleSaveButton(false);
	}
});

$('button#btn-save-records').on('click', function() {
	var confirmMessage = 'Are you sure you want to save the following changes? This cannot be undone!';
	if (numRecordsToCreate > 0) {
		confirmMessage += ('\n\nCreate ' + numRecordsToCreate + ' record(s)');
	}
	if (recordIdsToUpdate.length > 0) {
		confirmMessage += ('\n\nUpdate ' + recordIdsToUpdate.length + ' record(s)');
	}
	if (recordIdsToDelete.length > 0) {
		confirmMessage += ('\n\nDelete ' + recordIdsToDelete.length + ' record(s)');
	}

	if (confirm(confirmMessage)) {
		submitChanges();
	}
});

function removeAllInstances(array, value) {
	return array.filter(function(item) {
		return item !== value;
	});
}

function removeRow(row) {
	$(row).closest('tr').remove();
	numRecordsToCreate--;
	recalculateRowNumbers();
	if (numRecordsToCreate < 1 &&
		recordIdsToUpdate.length < 1 &&
		recordIdsToDelete.length < 1) {
		toggleSaveButton(false);
	}
}

function recalculateRowNumbers() {
	$('div#records-container table tbody tr').each(function(index) {
		var rowNum = (index + 1);
		$(this).attr('data-row-num', rowNum);
		$(this).find('td.row-num').html(rowNum);
	});
}

function toggleSaveButton(enabled) {
	$('button#btn-save-records').toggleClass('disabled', !enabled);
}

function submitChanges() {
	$.ajax({
		url: window.location.pathname,
		type: 'POST',
		contentType: 'application/json',
		data: JSON.stringify({
			creations: serializeCreations(),
			updates: serializeUpdates(),
			deletions: serializeDeletions()
		}),
		success: function(response) {
			location.reload();
		},
		error: function(response) {
			if (response.status == 422) {
				renderRowErrors(response.responseJSON);
			} else {
				renderInternalError(response.responseJSON.error);
			}
		}
	});
}

function serializeCreations() {
	var rows = $('div#records-container tbody tr[data-id="-1"]');
	return rows.toArray().map(function(row) {
		// For each row, return a JS object including the created record's data
		return {
			rowNum: $(row).attr('data-row-num'),
			data: arrayToHash($(row).find('td.editable').toArray().map(function(cell) {
				var colName = $(cell).attr('data-col');
				var value = $(cell).find('div.col-edit > input').val();
				if (value != '' && value != null) {
					return [colName, value];
				}
			}).removeNulls())
		}
	});
}

function serializeUpdates() {
	var rows = $('div#records-container tbody tr[data-id!="-1"]');
	return rows.toArray().filter(function(row) {
		// First collect all edited rows
		return recordIdsToUpdate.includes(Number($(row).attr('data-id')));
	}).map(function(row) {
		// For each row, return a JS object including the record id and updated data
		return {
			rowNum: $(row).attr('data-row-num'),
			id: $(row).attr('data-id'),
			data: arrayToHash($(row).find('td.editable').toArray().map(function(cell) {
				var oldValue = $(cell).find('div.col-read > input').val();
				var newValue = $(cell).find('div.col-edit > input').val();
				if (oldValue != newValue) {
					var colName = $(cell).attr('data-col');
					return [colName, newValue];
				}
			}).removeNulls())
		}
	});
}

function serializeDeletions() {
	// Return array of objects including the row numbers and ids to be deleted
	return recordIdsToDelete.map(function(id) {
		var rowNum = $('div#records-container tbody tr[data-id!='+id+']').attr('data-row-num');
		return { rowNum: rowNum, id: id };
	});
}

function renderRowErrors(errors) {
	$('div#errors').html([
		buildErrorHTML(errors.updates, 'update'),
		buildErrorHTML(errors.deletions, 'deletion'),
		buildErrorHTML(errors.creations, 'creation')
	].join(''));
	scrollToTopOfPage();
}

function renderInternalError(error) {
	$('div#errors').html('<div><b>SERVER ERROR</b>: '+error+'</div>')
}

// errors is an array of hashes where each hash has keys rowNum and error
function buildErrorHTML(errors, type) {
	if (errors.length < 1) { return ''; }
	var header = ('<div><b>'+type.toUpperCase()+' ERRORS</b></div>');
 	return (header + errors.map(function(err) {
		return ('<div><b><a onclick="scrollToRow('+err.rowNum+');" style="cursor: pointer;">Row '+err.rowNum+'</a></b>: '+err.error+'</div>');
	}).join(''));
}

function scrollToTopOfPage() {
	$('html, body').animate({ scrollTop: 0 }, scrollDurationMillis);
}

function scrollToRow(rowNum) {
	var row = $('div#records-container tbody tr[data-row-num='+rowNum+']');
	var location = (row.offset().top - (viewportHeight / 2));
	$('html, body').animate({ scrollTop: location }, scrollDurationMillis);
}

// Takes array where each element is an array with two elements.
// e.g. [['name', 'Bob'], ['age', '35']]
// returns: {name: 'Bob', age: '35'}
function arrayToHash(pairs) {
	return pairs.reduce(function(prev, curr) {
		prev[curr[0]] = curr[1];
		return prev;
	}, {});
}

Array.prototype.removeNulls = function() {
	return this.filter(function(x) {
		return x != null
	});
}
