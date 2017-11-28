var recordIdsToUpdate = [];
var recordIdsToDelete = [];

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
	if (recordIdsToUpdate.length < 1 && recordIdsToDelete.length < 1) {
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
	if (recordIdsToUpdate.length < 1 && recordIdsToDelete.length < 1) {
		toggleSaveButton(false);
	}
});

$('button#btn-save-records').on('click', function() {
	var confirmMessage = 'Are you sure you want to save the following changes?';
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

function toggleSaveButton(enabled) {
	$('button#btn-save-records').toggleClass('disabled', !enabled);
}

function submitChanges() {
	$.ajax({
		url: window.location.pathname,
		type: 'POST',
		contentType: 'application/json',
		data: JSON.stringify({
			creations: [],
			updates: serializeUpdates(),
			deletions: recordIdsToDelete
		}),
		success: function(response) {
			location.reload();
		},
		error: function(response) {
			renderErrors(response.responseJSON);
		}
	});
}

function serializeUpdates() {
	var rows = $('div#records-container tbody tr[data-id]');
	return rows.toArray().filter(function(row) {
		// First collect all edited rows
		return recordIdsToUpdate.includes(Number($(row).attr('data-id')));
	}).map(function(row) {
		// For each row, return a JS object including the record id and updated data
		return {
			id: $(row).attr('data-id'),
			updates: arrayToHash($(row).find('td.editable').toArray().map(function(cell) {
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

function renderErrors(errors) {
	console.log('ERRORS!');
	debugger;
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
