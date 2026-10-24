# frozen_string_literal: true

# Replaces `lib/tasks/auto_annotate_models.rake`: annotate 3.2.0 caps activerecord below 8.0 and
# cannot be resolved beside Rails 8, and annotaterb is that repository's maintained successor.
# The options the old file passed to `Annotate.set_defaults` live in `.annotaterb.yml` now.
if Rails.env.development? && ENV["ANNOTATERB_SKIP_ON_DB_TASKS"].nil?
  require "annotate_rb"
  AnnotateRb::Core.load_rake_tasks
end
