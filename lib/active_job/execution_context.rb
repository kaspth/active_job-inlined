require "active_support"
require "active_support/current_attributes"

class ActiveJob::ExecutionContext < ActiveSupport::CurrentAttributes
  module Integration
    def self.included(job)
      job.before_perform :set_context_job
      job.singleton_class.delegate :executing?, to: ActiveJob::ExecutionContext
    end

    def set_context_job
      ActiveJob::ExecutionContext.job = self
    end
  end

  attribute :job

  def executing?
    job.present?
  end

  def in_job?(object)
    executing? && job.arguments.include?(object)
  end
end
