class Agent < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: %w[online offline busy] }
  validates :capabilities, presence: true

  def available?
    status == 'online'
  end

  def update_last_seen!
    update(last_seen_at: Time.current)
  end

  def mark_as_offline!
    update(status: 'offline')
  end

  def mark_as_online!
    update(status: 'online')
  end

  def mark_as_busy!
    update(status: 'busy')
  end
end
