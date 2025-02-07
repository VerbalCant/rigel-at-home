class Task < ApplicationRecord
  belongs_to :agent, optional: true
  belongs_to :task_definition

  validates :name, presence: true
  validates :code, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending assigned running completed failed] }

  before_validation :set_initial_status, on: :create
  before_save :ensure_result_is_hash
  before_save :ensure_progress_data_is_hash

  scope :pending, -> { where(status: 'pending') }
  scope :running, -> { where(status: 'running') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }

  def start!
    update!(status: 'running', started_at: Time.current)
  end

  def complete!(result_data)
    update!(
      status: 'completed',
      completed_at: Time.current,
      result: result_data
    )
  end

  def fail!(error_message)
    update!(
      status: 'failed',
      completed_at: Time.current,
      result: { error: error_message }
    )
  end

  private

  def set_initial_status
    self.status ||= 'pending'
  end

  def ensure_result_is_hash
    self.result = {} if result.nil?
  end

  def ensure_progress_data_is_hash
    self.progress_data = {} if progress_data.nil?
  end
end
