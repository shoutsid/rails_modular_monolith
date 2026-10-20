# frozen_string_literal: true

# annotate is not installed: every release caps ActiveRecord below 8.0 (3.2.0)
# or rake below 11 (2.6.7), and this tree runs Rails 8.x with rake 13. The
# annotation task is a development convenience, so it is absent rather than
# pinned to a combination that cannot resolve.
