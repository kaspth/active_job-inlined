# frozen_string_literal: true

require_relative "inlined/version"

module ActiveJob; end
require_relative "execution_context"

module ActiveJob::Inlined
  using Module.new {
    refine Module do
      def invert_method(invert_method, original_method)
        class_eval "def #{invert_method}; !#{original_method}; end", __FILE__, __LINE__ + 1
      end
    end
  }

  def self.extended(klass)
    klass.include ActiveJob::ExecutionContext::Integration
  end

  def inlined
    inlineable? ? Proxy.new(self) : self
  end

  def inlineable?
    executing? && inline_enrolled?
  end

  def inline_exempt?
    @inline_exemption&.call(self)
  end
  invert_method :inline_enrolled?, :inline_exempt?

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

  class Proxy
    def initialize(job)
      @job = job
    end

    def perform_later(...)
      @job.perform_now(...)
      nil
    end

    def self.chains_on(method)
      class_eval "def #{method}(...); self.class.new @job.#{method}(...); end", __FILE__, __LINE__ + 1
    end
    chains_on :set
    chains_on :with
  end
end
