$('#select-study').on('change', function() {
	var selectedStudyId = $(this).val();
	if (selectedStudyId == 'all') {
		window.location = '/admin/users';
	} else {
		window.location = ('/admin/users?study=' + selectedStudyId);
	}
});
