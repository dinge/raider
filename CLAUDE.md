# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Raider is a Ruby gem that provides a framework for building LLM-powered agents and tasks. It supports multiple LLM providers (OpenAI, Ollama, Together) and allows for composable task execution with tool calling capabilities.

## Development Commands

### Setup
```bash
bundle install
bin/setup
```

### Testing
```bash
# Run all tests (minitest)
rake test

# Run specific test file
ruby test/rename_pdfs_test.rb

# Run RSpec tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Run both tests and linter (default rake task)
rake
```

### Console
```bash
bin/console  # Opens IRB with raider loaded
```

### Linting
```bash
bundle exec rubocop          # Check for style violations
bundle exec rubocop -a       # Auto-correct violations
```

## Architecture

### Core Concepts

Raider follows a layered architecture with the following key components:

1. **Apps** (`lib/raider/apps/`) - Top-level orchestrators that coordinate tasks and agents
   - `Apps::Base` provides context management, persistence hooks, and task/agent execution
   - Apps initialize with configurable context including provider, LLM, debug settings, VCR recording, retries, and lifecycle hooks

2. **Agents** (`lib/raider/agents/`) - High-level processors that can run multiple tasks
   - `Agents::Base` wraps task execution with input/output management
   - Agents are executed via `AgentRunner` and can chain multiple tasks together

3. **Tasks** (`lib/raider/tasks/`) - Individual LLM operations with specific prompts
   - `Tasks::Base` defines the interface for all tasks (prompt, system_prompt, tools, example_response_struct)
   - Tasks can be model-specific via nested namespaces (e.g., `FetchBasicLetterInfo::Gemma3Large`)
   - Tasks support tool calling for function execution during LLM interactions
   - Each task has its own context (`TaskContext`) tracking input/output, tool calls, and LLM usage

4. **Providers** (`lib/raider/providers/`) - Abstractions for different LLM APIs
   - Each provider (Ollama, OpenAI, Together) defines available models and message formatting
   - Providers handle model-specific request/response formats and tool call parsing
   - Use `ruby_llm_client_class` to integrate with Langchain's LLM clients

5. **LLMs** (`lib/raider/llms/`) - Model configurations and options
   - Each LLM class corresponds to a specific model (e.g., `Gemma3Small`, `Gpt4oMini`)
   - Defines default options like format, temperature, etc.

6. **Runners** (`lib/raider/runners/`) - Execution engines
   - `TaskRunner` executes individual tasks, manages chat messages, handles tool calls
   - `AgentRunner` executes agents, coordinates task sequences
   - `AppRunner` orchestrates app-level execution (mostly placeholder)

### Execution Flow

```
App → Agent → Task → Provider → LLM API
     ↓         ↓       ↓
  AppContext AgentContext TaskContext
```

**Typical execution:**
1. App initializes with context (provider, LLM, hooks, etc.)
2. App creates a TaskRunner or AgentRunner
3. Runner processes the task/agent, building messages and calling LLM
4. Task defines the prompt, system prompt, and optional tools
5. Provider formats messages and sends to LLM API via Langchain
6. Runner processes response (including tool calls if present)
7. Results stored in context hierarchy (TaskContext → AgentContext → AppContext)

### Tool Calling

Tasks can define tools (functions) that the LLM can call:
- Tools defined in task's `tools` method
- When LLM returns tool calls, runner executes corresponding `*_tool` methods on the task
- Tool responses sent back to LLM for final processing
- Lifecycle hooks: `on_tool_call`, `on_tool_response`, `on_tool_process`, `on_tool_process_response`

### Context System

Three levels of context:
- **AppContext** - Global app state, configuration, lifecycle hooks
- **AgentContext** - Agent-specific input/tasks/data
- **TaskContext** - Task-specific input/output, tool calls, LLM usages

Contexts use `Utils::BaseContext` with RecursiveOpenStruct for flexible data access.

### Logging and VCR

- Logging via `Raider.logger` - set to DEBUG in development via `debug: true` in app context
- VCR support for recording/replaying LLM interactions (configured via `with_vcr` and `vcr` options)
- Log files in `log/raider/`

## Advanced Usage Patterns

### Agent DSL Pattern (Preferred)

The recommended way to orchestrate multiple tasks is using the agent DSL pattern with blocks:

```ruby
class AnswerGorgiasTicket < Raider::Apps::Base
  def process
    app.agents.answer_gorgias_ticket(input:) do |ag|
      # Tasks return results directly
      classify = ag.tasks.classify_ticket(llm: :gpt5_mini, input:)
      
      # Pass results to next task via inputs parameter
      products = ag.tasks.query_pim_products(
        input:,
        inputs: { classify_ticket: classify }
      )
      
      # Chain multiple tasks with accumulated context
      response = ag.tasks.write_final_response(
        input:,
        inputs: {
          classify_ticket: classify,
          pim_products: products,
          vector_store: ag.tasks.search_vector_store(input:)
        }
      )
      
      # Store final output
      ag.add_to_output!(output: response[:text])
    end
  end
end
```

**Benefits:**
- Declarative workflow definition
- Automatic input/output tracking
- Built-in timing and logging
- Clear data flow between tasks

### Tool Definition Pattern

Tools are defined by subclassing `Raider::ToolBase` and implementing the schema and execution:

```ruby
class PimProducts < Raider::ToolBase
  DATASET = :pim_products
  
  def name
    'search_pim_products'
  end
  
  def description
    'Search product catalog by keywords, brand, category'
  end
  
  def parameters
    {
      query: {
        type: :string,
        description: 'Search query for products'
      },
      brand: {
        type: :string,
        description: 'Filter by brand name'
      },
      limit: {
        type: :integer,
        description: 'Maximum number of results'
      }
    }
  end
  
  def required
    ['query']
  end
  
  def self.process(query:, brand: nil, limit: 10)
    # Implement tool logic
    results = Pim::Product.search(query)
    results = results.where(brand: brand) if brand.present?
    results.limit(limit).map(&:to_h)
  end
end
```

### Task Structure Best Practices

Tasks should define clear prompts with structured JSON responses:

```ruby
class ClassifyTicket < Raider::Tasks::Base
  def process(input:, inputs:)
    @input = input
    @inputs = inputs
    set_system_prompt(system_prompt)
    chat(prompt)
  end
  
  def system_prompt
    <<~SYSTEM
      You are a customer service ticket classifier.
      Analyze tickets and categorize them accurately.
      
      Available categories: #{@inputs[:available_categories].join(', ')}
    SYSTEM
  end
  
  def prompt
    <<~PROMPT
      Analyze this customer ticket: #{@input}
      
      #{json_instruct}
    PROMPT
  end
  
  def example_response_struct
    {
      category: 'product/defect',
      language: 'en',
      keywords: ['keyword1', 'keyword2'],
      customer_name: 'John Doe',
      order_number: '12345',
      intent_count: 1,
      intent_summarization: 'Customer reports defect'
    }
  end
end
```

### Conditional Task Execution

Use Ruby conditionals to create dynamic workflows:

```ruby
app.agents.answer_ticket(input:) do |ag|
  # Early exit on spam detection
  attack = ag.tasks.analyze_attack(llm: :gpt5_mini, input:)
  if attack[:is_attack]
    ag.add_to_output!(output: attack[:attack_explanation])
    next
  end
  
  # Conditional translation
  classify = ag.tasks.classify_ticket(llm: :gpt5_mini, input:)
  if classify[:language] != 'en'
    translated = ag.tasks.translate(
      input: classify[:text],
      inputs: { target_language: 'en' }
    )
  end
  
  # Continue with workflow...
end
```

### Response Helpers Pattern

Use `ag.response_from` for external data fetching with naming:

```ruby
ag.response_from.order_infos do
  ExternalAPI.fetch_orders(customer_id)
end

# Access later in workflow via ag context
ag.tasks.write_response(
  inputs: { order_infos: ag.order_infos }
)
```

### Retries and Error Handling

Implement retry logic for quality assurance:

```ruby
def run_final_response_task(ag, input:, classify:, num_runs: 0)
  response = ag.tasks.write_final_response(
    input:,
    inputs: { classify: }
  )
  
  # Verify response quality
  language = ag.tasks.detect_language(input: response[:text])
  
  if language[:language] == classify[:language] || num_runs >= 3
    response
  else
    # Retry if language doesn't match
    run_final_response_task(ag, input:, classify:, num_runs: num_runs + 1)
  end
end
```

### Task Aliasing with `as:`

Tasks can be aliased for clearer context tracking:

```ruby
ag.tasks.translate(
  input: german_text,
  inputs: { destination_locale: :en },
  as: :translate_to_english
)

# Access via alias
ag.context.outputs[:translate_to_english]
```

### Integration with Rails

When used in Rails apps, Raider integrates with ActiveRecord models:

```ruby
# Create a Raider::App record that persists execution
class Raider::App < ApplicationRecord
  belongs_to :upstream, polymorphic: true
  
  # Store all context in JSONB columns
  # inputs, outputs, context, metadata, hil_inputs
end

# Create Raider::Source for dataset tracking
class Raider::Source < ApplicationRecord
  # dataset: :gorgias_tickets, :user_requests, etc.
  # source_ident: external ID
  # title, input, context as JSONB
end

# Run app with persistence
app = AnswerGorgiasTicket.new(
  with_app_persistence: true,
  upstream: source
).process!
```

### Lifecycle Hooks

Configure hooks for workflow events:

```ruby
AnswerTicket.new(
  on_tool_call: :log_tool_usage,
  on_tool_response: :validate_tool_response,
  on_task_response: :broadcast_update
).process!

# In app class
def log_tool_usage(task, tool_method, tool_args)
  Rails.logger.info "Task #{task.ident} calling #{tool_method}"
end
```

## Code Style

- RuboCop configured with Rails cops
- Target Ruby version: 3.4
- Line length: 120 characters
- Documentation disabled (Style/Documentation)
- See `.rubocop.yml` for customizations

## Dependencies

Key gems:
- **langchainrb** - LLM client abstraction
- **ruby-openai** - OpenAI API client
- **zeitwerk** - Auto-loading
- **activesupport** - Rails utilities
- **pdf-reader**, **ruby-vips** - Document processing
- **slop** - CLI argument parsing
- **json-schema-generator**, **simple_json_schema_builder** - JSON schema tools
