# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "active_job"
require "active_job/inlined"

class ApplicationJob < ActiveJob::Base
  extend ActiveJob::Inlined
end

class Post
  mattr_accessor :published

  def publish
    self.published = true
  end

  class PublishJob < ApplicationJob
    def perform
      Post.new.publish
    end
  end
end

require "minitest/autorun"
