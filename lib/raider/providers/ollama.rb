# frozen_string_literal: true

module Raider
  module Providers
    class Ollama < Base
      MODELS = {
        gemma3_small: {
          chat_model: 'gemma3:12b'
        },
        gemma3_large: {
          chat_model: 'gemma3:27b'
        },
        llama3v2_vision_small: {
          chat_model: 'llama3.2-vision:11b'
        },
        phi4: {
          chat_model: 'phi4:latest'
        },
        qwen2_vl_small: {
          chat_model: 'siasi/qwen2-vl-7b-instruct:latest'
        },
        granite3v22b_fp16: {
          chat_model: 'granite3.2-vision:2b-fp16'
        },
        openfree_qwen2v5_vl32b_q8: {
          chat_model: 'hf.co/openfree/Qwen2.5-VL-32B-Instruct-Q8_0-GGUF:Q8_0'
        },
        unsloth_gemma3_27b_Q5: {
          chat_model: 'hf.co/unsloth/gemma-3-27b-it-GGUF:Q5'
        },
        unsloth_qwen2v5_vl32b_q4: {
          chat_model: 'hf.co/openfree/Qwen2.5-VL-32B-Instruct-Q4_K_M-GGUF:Q4_K_M'
        },
        qwen2v532b: {
          chat_model: 'qwen2.5:32b'
        }
      }.freeze

      def ruby_llm_client_class
        Langchain::LLM::Ollama
      end

      def provider_options
        { default_options: }
      end

      def default_options
        {
          chat_model: default_model,
          system: system_prompt
        }
      end

      def to_messages_basic_to_json(prompt:)
        to_message_with do
          [{
            role: 'user',
            content: prompt,
            response_format: 'json'
          }]
        end
      end

      def to_messages_basic_with_images_to_json(prompt:, images:)
        to_message_with do
          [{
            role: 'user',
            content: prompt,
            images: images,
            response_format: 'json'
          }]
        end
      end

      def parse_raw_response(raw_response)
        raw_response.dig('message', 'content')
      end
    end
  end
end

# mistral-small3.1:latest
# granite3.2-vision:latest
# jyan1/paligemma-mix-224:latest
# gemma3:12b
# moondream:latest
# minicpm-v:latest
# bakllava:latest
# siasi/qwen2-vl-7b-instruct:latest
# qwen2.5:14b
# bakllava:7b
# phi4:latest
# llava:7b
# llama3.2-vision:11b
# hf.co/abetlen/paligemma-3b-mix-224-gguf:latest
# llava-phi3:latest

# deepseek-coder-v2:latest
# hf.co/bartowski/DeepSeek-R1-Distill-Qwen-32B-GGUF:IQ2_S
# hf.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF:Q2_K
# deepseek-r1:14b
# llama2-uncensored:latest
# llama3.2:latest
