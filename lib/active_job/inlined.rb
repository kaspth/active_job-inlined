# frozen_string_literal: true

require "active_support"
require "active_support/current_attributes"

module ActiveJob; end

module ActiveJob::Inlined
  autoload :VERSION, "inlined/version"

  def self.extended(klass) = klass.before_perform { Current.job = self }

  def inlined
    inlineable? ? Proxy.new(self) : self
  end

  # By default, jobs are considered inlineable. But they can declare themselves
  # exempt by calling `inline_exempt`, like this:
  #
  #   class Post::PublishJob < ApplicationJob
  #     inline_exempt
  #     inline_exempt -> job { job.arguments.size.even? }
  #     inline_exempt { |job| job.arguments.size.even? }
  #   end
  def inline_exempt(context = nil, &block)
    @inline_exemption = context || block || proc { true }
  end

  private
    def inlineable?
      Current.job? && !@inline_exemption&.call(self)
    end

    class Current < ActiveSupport::CurrentAttributes
      attribute :job
      alias_method :job?, :job
    end

    class Proxy < Struct.new(:job)
      def perform_later(...)
        job.perform_now(...)
        nil
      end

      def set(...)  = self.class.new(job.set(...))
      def with(...) = self.class.new(job.with(...))
    end
end
