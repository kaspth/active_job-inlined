# frozen_string_literal: true

require "test_helper"

class ActiveJob::TestInlined < Minitest::Test
  def setup
    super
    Post.published = false
  end

  def test_that_it_has_a_version_number
    refute_nil ::ActiveJob::Inlined::VERSION
  end

  def test_running_inlined
    Post::PublishJob.inlined.perform_later
    assert Post.published
  end
end
