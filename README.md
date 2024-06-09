# ActiveJob::Inlined

`ActiveJob::Inlined` lets you run jobs inline within other jobs.

Set this up in your app:

```ruby
class ApplicationJob < ActiveJob::Base
  extend ActiveJob::Inlined
end
```

Then use it:

```ruby
class Post < ActiveRecord::Base
  def release_later
    Release::SequenceJob.perform_later self
  end

  def release
    prep_marketing_department pizzazz_required: "✨✨✨✨"
    some_other_step
    # …then more stuff in the sequence, but at one point we run:
    publish_later
  end

  def publish_later
    # Now, we mark the job as `inlined`, i.e. we'll really call `perform_now`
    # if we're within another job (or do the usual `perform_later` if not).
    PublishJob.inlined.perform_later self
  end

  def publish
    puts "lol"
  end
end

class Post::Release::SequenceJob < ApplicationJob
  def perform(post) = post.release
end

class Post::PublishJob < ApplicationJob
  def perform(post) = post.publish
end
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add active_job-inlined

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install active_job-inlined

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kaspth/active_job-inlined.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
