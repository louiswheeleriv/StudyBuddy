Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root 'home#home'

	get 'login',   to: 'session#new'
  post 'login',   to: 'session#create'
  get 'logout',  to: 'session#destroy'

	get 'dashboard', to: 'dashboard#dashboard'

	get 'admin', to: 'admin#admin'
	get 'admin/signup', to: 'admin#signup'
	post 'admin/signup', to: 'admin#signup_submit'
	get 'admin/signup/load_study_phases', to: 'admin#load_study_phases'
	post 'test_sms', to: 'admin#test_sms'
	get 'admin/users', to: 'admin#users'
	get 'admin/manage', to: 'admin#manage'
	get 'admin/manage/studies', to: 'admin#manage_studies'
	get 'admin/manage/phases', to: 'admin#manage_phases'
	get 'admin/manage/questions', to: 'admin#manage_questions'
	get 'admin/manage/users', to: 'admin#manage_users'
	get 'admin/manage/user_schedules', to: 'admin#manage_user_schedules'
	get 'admin/manage/user_phases', to: 'admin#manage_user_phases'
	get 'admin/manage/user_data', to: 'admin#manage_user_data'

	get 'study/:study_id', to: 'study#study', constraints: { study_id: /.*/ }
end
