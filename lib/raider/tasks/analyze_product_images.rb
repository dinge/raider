# frozen_string_literal: true

module Raider
  module Tasks
    class AnalyzeProductImages < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)

        # Handle both single image and multiple images
        images = if input.is_a?(Array)
                   input
                 elsif input.is_a?(String) && File.exist?(input)
                   [input]
                 else
                   []
                 end

        if images.any?
          chat_message_with_images(prompt, images)
        else
          chat(prompt_without_images)
        end
      end

      def system_prompt
        <<~SYSTEM
          You are a product photography and e-commerce optimization expert with deep knowledge of:
          - Visual merchandising and product presentation
          - Consumer psychology and buying triggers
          - Product feature identification and categorization
          - Image quality assessment for e-commerce
          - Brand positioning through visual elements

          Your role is to analyze product images and extract actionable insights that will be used
          to create compelling, conversion-optimized product listings.

          Focus on:
          1. Primary product identification and categorization
          2. Key visual features and selling points
          3. Product condition, quality, and presentation
          4. Target audience indicators
          5. Unique selling propositions visible in the image
          6. Image quality and areas for improvement
        SYSTEM
      end

      def prompt
        context = if @inputs[:current_title].present?
                    "\nCurrent listing title: #{@inputs[:current_title]}"
                  else
                    ""
                  end

        context += if @inputs[:current_description].present?
                     "\nCurrent description: #{@inputs[:current_description]}"
                   else
                     ""
                   end

        <<~TEXT
          Analyze these product images in detail to extract information for creating an optimized e-commerce listing.
          #{context}

          Please provide:
          1. What is this product? (Be specific - brand, model, type, variant)
          2. What are the key visual features and selling points?
          3. What condition/quality is evident from the images?
          4. Who is the likely target customer?
          5. What makes this product unique or special?
          6. What is the primary use case or benefit?
          7. Any quality issues with the images themselves?
          8. Suggestions for additional photos that would help selling

          Be detailed and specific - this analysis will drive the listing optimization.

          #{json_instruct}
        TEXT
      end

      def prompt_without_images
        <<~TEXT
          Analyze the product based on the provided text information.

          Current title: #{@inputs[:current_title]}
          Current description: #{@inputs[:current_description]}
          Category: #{@inputs[:category]}

          Extract what you can determine about the product.

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          product_identification: {
            product_type: 'Wireless Bluetooth Headphones',
            brand: 'Sony',
            model: 'WH-1000XM5',
            category: 'Electronics > Audio > Headphones',
            subcategory: 'Over-Ear Wireless Headphones'
          },
          key_features: [
            'Active Noise Cancellation technology',
            'Premium leather ear cups',
            'Foldable design with carrying case',
            'Touch controls visible on ear cup',
            'USB-C charging port',
            'Multiple color options shown'
          ],
          visual_quality: {
            overall_quality: 'excellent',
            lighting: 'professional studio lighting',
            angles: 'multiple angles showing all features',
            background: 'clean white background',
            resolution: 'high resolution, zoomable details',
            issues: []
          },
          selling_points: [
            'Premium build quality evident from materials',
            'Sleek, modern design appeals to professionals',
            'Compact folding mechanism for portability',
            'Professional studio photography increases trust',
            'Multiple product views show attention to detail'
          ],
          target_audience: {
            primary: 'Working professionals 25-45',
            secondary: 'Frequent travelers, audiophiles',
            use_cases: ['Office/remote work', 'Travel', 'Music listening', 'Gaming']
          },
          unique_selling_propositions: [
            'Industry-leading noise cancellation',
            'Premium materials and build quality',
            'Recognizable brand reputation',
            'Complete package with accessories'
          ],
          condition_assessment: 'New, appears to be unopened with all original packaging',
          image_improvements: [
            'Add lifestyle photo showing product in use',
            'Include size comparison with common object',
            'Show close-up of touch controls',
            'Demonstrate folding mechanism'
          ],
          estimated_price_range: '$250-400 based on brand and features',
          seasonality: 'Year-round demand, peaks in Q4 holidays',
          competitive_positioning: 'Premium segment, competes with Bose, Apple AirPods Max'
        }
      end
    end
  end
end
