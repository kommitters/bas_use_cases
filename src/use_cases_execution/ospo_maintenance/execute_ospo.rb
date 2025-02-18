# frozen_string_literal: true

require 'timeout'

TASKS = [
  { path: File.expand_path('./projects/bas.rb', __dir__) },
  { path: File.expand_path('./projects/chaincerts_dapp.rb', __dir__) },
  { path: File.expand_path('./projects/chaincerts_prototype.rb', __dir__) },
  { path: File.expand_path('./projects/chaincerts_smart_contracts.rb', __dir__) },
  { path: File.expand_path('./projects/editor_js_undo.rb', __dir__) },
  { path: File.expand_path('./projects/editorjs_break_line.rb', __dir__) },
  { path: File.expand_path('./projects/editorjs_drag_drop.rb', __dir__) },
  { path: File.expand_path('./projects/editorjs_inline_image.rb', __dir__) },
  { path: File.expand_path('./projects/editorjs_toggle_block.rb', __dir__) },
  { path: File.expand_path('./projects/editorjs_tooltip.rb', __dir__) },
  { path: File.expand_path('./projects/elixir_xdr.rb', __dir__) },
  { path: File.expand_path('./projects/kadena_ex.rb', __dir__) },
  { path: File.expand_path('./projects/mintacoin.rb', __dir__) },
  { path: File.expand_path('./projects/mtk_automation.rb', __dir__) },
  { path: File.expand_path('./projects/soroban_ex.rb', __dir__) },
  { path: File.expand_path('./projects/soroban_smart_contracts.rb', __dir__) },
  { path: File.expand_path('./projects/stellar_base.rb', __dir__) },
  { path: File.expand_path('./projects/stellar_sdk.rb', __dir__) },
  { path: File.expand_path('./projects/tickspot_js.rb', __dir__) }
].freeze

POST_TASKS = [
  { path: File.expand_path('./verify_issue_existance_in_notion.rb', __dir__) }
].freeze

# Function to execute a single task with a timeout
def run_task(task)
  puts "Running task: #{task[:path]}"
  begin
    Timeout.timeout(300) do # 5 minutes timeout per task
      system("ruby #{task[:path]}")
    end
  rescue Timeout::Error
    puts "Task #{task[:path]} was stopped after 5 minutes."
  rescue StandardError => e
    puts "Error executing #{task[:path]}: #{e.message}"
  end
end

def run_post_tasks
  POST_TASKS.each do |post_task|
    puts "Running post-task: #{post_task[:path]}"
    run_task(post_task)
  end
end

unless defined?(RSpec)
  begin
    Timeout.timeout(300) do # 5 minutes timeout for the entire script
      loop do
        TASKS.each do |task|
          # Execute the main task
          run_task(task)

          # Execute the post-tasks after the main task
          puts "Running post-tasks for #{task[:path]}..."
          run_post_tasks

          puts "Completed: #{task[:path]}\n\n"
          sleep 5 # Wait for 5 seconds before the next task
        end
      end
    end
  rescue Timeout::Error
    puts "\nOSPO execution stopped after 5 minutes."
  end
end
