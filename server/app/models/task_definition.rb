class TaskDefinition < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true
  validates :requirements, presence: true

  def create_task!(agent = nil)
    tasks.create!(
      name: name,
      description: description,
      code: code,
      agent: agent,
      status: agent.present? ? 'assigned' : 'pending'
    )
  end

  def compatible_with_agent?(agent)
    return false unless agent.capabilities.is_a?(Hash) && requirements.is_a?(Hash)

    requirements.all? do |requirement, value|
      case requirement
      when 'min_memory'
        agent.capabilities['memory'].to_i >= value.to_i
      when 'min_cpu_cores'
        agent.capabilities['cpu_cores'].to_i >= value.to_i
      when 'required_features'
        value.all? { |feature| agent.capabilities['features']&.include?(feature) }
      else
        true
      end
    end
  end
end
