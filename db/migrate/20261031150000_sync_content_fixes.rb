require Rails.root.join("lib/content_sync")

# Phase 0 content fixes: look-alike Cyrillic letters, typos, wrong definitions
# and outdated numbers. The CSVs are the source; this applies them to existing data.
class SyncContentFixes < ActiveRecord::Migration[8.1]
  def up
    Question.reset_column_information
    changed = ContentSync.call(log: ->(message) { say(message) })
    say "#{changed} records updated"
  end

  def down
    # Content edits are not reverted
  end
end
