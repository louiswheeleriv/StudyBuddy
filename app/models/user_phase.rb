class UserPhase < ApplicationRecord
  belongs_to :phase
  belongs_to :user
end
