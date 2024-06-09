# frozen_string_literal: true

require_relative "inlined/version"

module ActiveJob; end
require_relative "execution_context"

module ActiveJob::Inlined
  def self.extended(klass) = klass.include(ActiveJob::ExecutionContext::Integration)

  def inlined
    inlineable? ? Proxy.new(self) : self
  end
  def inlineable? = executing? && inline_enrolled?

  def inline_enrolled? = !inline_exempt?
  def inline_exempt?   = @inline_exemption&.call(self)

  # By default, jobs are considered inlineable. But they can declare themselves
  # exempt by calling `inline_exempt`, like this:
  #
  #   class Post::PublishJob < ApplicationJob
  #     inline_exempt
  #     inline_exempt -> job { job.arguments.size.even? }
  #     inline_exempt { |job| job.arguments.size.even? }
  #   end
  def inline_exempt(context = nil, &block)
    @inline_exemption = context || block || -> { true }
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
