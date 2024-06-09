# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "active_job"
require "active_job/inlined"

require "minitest/autorun"

class ApplicationJob < ActiveJob::Base
  extend ActiveJob::Inlined
end

class Post
  mattr_accessor :published

  def publish
    self.published = true
  end

  # We're calling a model method to check the `inlined` works correctly across the
  # job -> model boundary.
  def submit_in_sequence
    Post::PublishJob.inlined.perform_later
  end

  class SequenceJob < ApplicationJob
    def perform = Post.new.submit_in_sequence
  end

  class PublishJob < ApplicationJob
    def perform = Post.new.publish
  end
end

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup { ActiveSupport::CurrentAttributes.clear_all }
  setup { Post.published = false }
end
