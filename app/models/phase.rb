class Phase < ApplicationRecord
  belongs_to :study
  belongs_to :prev_phase
end
