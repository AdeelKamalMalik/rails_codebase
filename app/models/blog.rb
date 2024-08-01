class Blog < ApplicationRecord
  belongs_to :user
  # Broadcast changes in realtime with Hotwire
  after_create_commit -> { broadcast_prepend_later_to :blogs, partial: "blogs/index", locals: {blog: self} }
  after_update_commit -> { broadcast_replace_later_to self }
  after_destroy_commit -> { broadcast_remove_to :blogs, target: dom_id(self, :index) }
end
