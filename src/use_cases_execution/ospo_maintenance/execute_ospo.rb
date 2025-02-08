# frozen_string_literal: true

require 'timeout'

# List of tasks to execute with correct paths
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
  { path: File.expand_path('./projects/tickspot_js.rb', __dir__) },
  { path: File.expand_path('./verify_issue_existance_in_notion.rb', __dir__) }
].freeze

# Function to execute a task with a maximum runtime of 5 minutes
def run_task(task)
  puts "Running task: #{task[:path]}"
  begin
    Timeout.timeout(300) do # 300 seconds = 5 minutes
      system("ruby #{task[:path]}")
    end
  rescue Timeout::Error
    puts "Task #{task[:path]} was stopped after 5 minutes."
  rescue StandardError => e
    puts "Error executing #{task[:path]}: #{e.message}"
  end
end

# Execute each task indefinitely with a 10-second interval
loop do
  TASKS.each do |task|
    run_task(task)
    puts "Completed: #{task[:path]}\n\n"
    sleep 10
  end
end
