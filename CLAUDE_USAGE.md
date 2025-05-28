# Claude Code Usage Guide

## Setup

### 1. Install Claude Code
```bash
# Install via npm
npm install -g @anthropic-ai/claude-code
```

### 2. Set up API Key
```bash
# Set your Anthropic API key as an environment variable
export ANTHROPIC_API_KEY="your_api_key_here"

# Or add it to your shell profile for persistence
echo 'export ANTHROPIC_API_KEY="your_api_key_here"' >> ~/.bashrc
source ~/.bashrc # or ~/.zshrc if using Zsh
```

You can get your API key from the [Anthropic Console](https://console.anthropic.com/).

## Usage Modes

### Interactive Mode
Start Claude Code in interactive mode to have a conversation:

```bash
# Start interactive session
claude

# Start with specific model
claude --model claude-3-5-sonnet-20241022

# Start with a specific prompt
claude "Help me understand the codebase structure"
```

### Non-Interactive Mode
Execute single commands without entering interactive mode:

```bash
# Run a single command
claude "Add tests for the birthday notification feature"

# Process a file
claude "Review this file for improvements" --file src/implementations/notify_discord.rb

# Execute with specific context
claude "Optimize the database queries in this use case" --directory src/use_cases_execution/birthday/
```

## Customizing Claude's Behavior

### CLAUDE.md Configuration
The `CLAUDE.md` file in the repository root contains instructions that Claude follows. You can customize Claude's behavior by editing this file.

#### Key Sections to Customize:

1. **Development Commands** - Update build/test/lint commands for your project
2. **Architecture Overview** - Describe your specific patterns and conventions
3. **Directory Structure** - Document your file organization
4. **Adding New Use Cases** - Define your development workflow
5. **Configuration** - Specify environment setup requirements

## Creating New BAS Use Cases

To create a new use case, craft a prompt specifying the data source, data output, formatting, and any other relevant instructions. Then paste your prompt in interactive mode or pass it as a `-p` argument:

```bash
claude -p "YOUR PROMPT" --allowedTools Read Edit Write Bash Glob LS
```

### Example Prompt Structure:
```
Create a new use case named [lowercase_name] that:
- Fetches data from [SOURCE]
- Formats it as [FORMAT]
- Sends notifications to [DESTINATION]
- Runs [SCHEDULE]
```

## Troubleshooting

### Common Issues:
- **API Key not working**: Verify the key is set correctly and has sufficient credits
- **Slow responses**: Large codebases may take longer to analyze
- **Context limits**: Break large tasks into smaller, focused requests
- **Permission errors**: Ensure Claude has access to the files and directories you're working with

### Getting Help:
- Use `/help` within interactive mode for built-in assistance
- Report issues at https://github.com/anthropics/claude-code/issues
