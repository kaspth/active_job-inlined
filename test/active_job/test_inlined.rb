# frozen_string_literal: true

require "test_helper"

class ActiveJob::TestInlined < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    ActiveSupport::CurrentAttributes.clear_all
    Post.published = false
  end

  test "version number" do
    refute_nil ::ActiveJob::Inlined::VERSION
  end

  test "nothing was broken" do
    assert_enqueued_jobs 1, only: Post::PublishJob do
      Post::PublishJob.perform_later
    end

    perform_enqueued_jobs
    assert Post.published
  end

  test "running inlined outside of job enqueues" do
    refute_predicate ActiveJob::ExecutionContext, :executing?

    assert_enqueued_jobs 1, only: Post::PublishJob do
      Post::PublishJob.inlined.perform_later
    end

    perform_enqueued_jobs
    assert Post.published
  end

  test "running inlined inside of a job executes it inline" do
    Post::SequenceJob.perform_now
    assert_no_enqueued_jobs
    assert Post.published
  end
end
