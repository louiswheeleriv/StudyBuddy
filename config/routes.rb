Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root 'home#home'

	get 'login',   to: 'session#new'
  post 'login',   to: 'session#create'
  get 'logout',  to: 'session#destroy'

	get 'dashboard', to: 'dashboard#dashboard'
	get 'questions', to: 'ptcpt_questions#questions'
	post 'questions/answer', to: 'ptcpt_questions#answer'
	get 'profile', to: 'ptcpt_profile#profile'
	post 'profile/update', to: 'ptcpt_profile#update'
	get 'contact', to: 'ptcpt_contact#contact'
	post 'contact/message', to: 'ptcpt_contact#message'

	get 'admin', to: 'admin#admin'
	get 'admin/signup', to: 'admin#signup'
	post 'admin/signup', to: 'admin#signup_submit'
	get 'admin/signup/load_study_phases', to: 'admin#load_study_phases'
	post 'test_sms', to: 'admin#test_sms'
	get 'admin/users', to: 'admin#users'
	get 'admin/manage', to: 'admin#manage_selection'
	get 'admin/manage/studies', to: 'admin#manage', model: Study
	get 'admin/manage/phases', to: 'admin#manage', model: Phase
	get 'admin/manage/questions', to: 'admin#manage', model: Question
	get 'admin/manage/users', to: 'admin#manage', model: User
	get 'admin/manage/user_studies', to: 'admin#manage', model: UserStudy
	get 'admin/manage/user_schedules', to: 'admin#manage', model: UserSchedule
	get 'admin/manage/user_phases', to: 'admin#manage', model: UserPhase
	get 'admin/manage/user_data', to: 'admin#manage', model: UserDatum
	post 'admin/manage/studies', to: 'admin#manage_submit', model: Study
	post 'admin/manage/phases', to: 'admin#manage_submit', model: Phase
	post 'admin/manage/questions', to: 'admin#manage_submit', model: Question
	post 'admin/manage/users', to: 'admin#manage_submit', model: User
	post 'admin/manage/user_schedules', to: 'admin#manage_submit', model: UserSchedule
	post 'admin/manage/user_phases', to: 'admin#manage_submit', model: UserPhase
	post 'admin/manage/user_data', to: 'admin#manage_submit', model: UserDatum

	get 'study/:study_id', to: 'study#study', constraints: { study_id: /.*/ }
end
