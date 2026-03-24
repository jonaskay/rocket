class MasterTraining < ApplicationRecord
  belongs_to :client
  belongs_to :trainer, class_name: "User"

  validates :title, presence: true

  validate :trainer_must_be_a_trainer

  private

  def trainer_must_be_a_trainer
    errors.add(:trainer, "must be a trainer") if trainer && !trainer.trainer?
  end
end
