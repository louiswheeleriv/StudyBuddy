# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += [
	'admin/signup.js',
	'admin/users.js',
	'admin/manage_db.js',
	'user_scheduler.js',
	'user_phase_edit.js',
	'user_info.js',
	'dashboard.js',
	'ptcpt_questions.js',
	'ptcpt_profile.js',
	'ptcpt_contact.js'
]
