# frozen_string_literal: true

module Raider
  module Tasks
    class ResearchCompetitors < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          You are an e-commerce competitive intelligence expert with deep knowledge of:
          - Amazon, eBay, Etsy, and Shopify marketplace dynamics
          - Product listing best practices across platforms
          - Keyword research and SEO optimization
          - Competitive pricing strategies
          - Consumer search behavior and buying triggers
          - Successful listing patterns and conversion tactics

          Your role is to analyze competitive landscape and provide actionable insights
          for optimizing product listings to outperform competitors.

          Focus on identifying:
          1. Common keywords and phrases top sellers use
          2. Effective title structures and patterns
          3. Compelling feature callouts and benefits
          4. Pricing strategies and positioning
          5. What makes top listings successful
          6. Gaps or opportunities in competitor listings
        SYSTEM
      end

      def prompt
        product_context = if @inputs[:image_analysis].present?
                           "Product: #{@inputs[:image_analysis][:product_identification][:product_type]}\n" \
                           "Category: #{@inputs[:image_analysis][:product_identification][:category]}\n" \
                           "Key Features: #{@inputs[:image_analysis][:key_features]&.join(', ')}"
                         else
                           "Product Category/Keywords: #{@input}"
                         end

        <<~TEXT
          Research the competitive landscape for this product to inform listing optimization.

          #{product_context}

          Based on your knowledge of successful e-commerce listings in this category, provide:

          1. **Top Keywords**: What keywords do successful listings use?
          2. **Title Patterns**: What title structures convert best?
          3. **Feature Callouts**: What product features do top sellers emphasize?
          4. **Price Positioning**: What price range is typical for this category?
          5. **Unique Angles**: What makes top listings stand out?
          6. **Common Mistakes**: What do unsuccessful listings do wrong?
          7. **Seasonal Trends**: Any timing considerations?
          8. **Target Keywords**: Specific keywords to target for SEO

          Provide specific, actionable insights based on e-commerce best practices.

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          category_analysis: {
            category: 'Wireless Headphones',
            competition_level: 'high',
            market_saturation: 'Very competitive, dominated by major brands',
            buyer_behavior: 'Price-sensitive but willing to pay premium for quality/features'
          },
          top_keywords: [
            {
              keyword: 'noise cancelling headphones',
              search_volume: 'high',
              competition: 'high',
              priority: 'primary'
            },
            {
              keyword: 'wireless bluetooth headphones',
              search_volume: 'very high',
              competition: 'very high',
              priority: 'primary'
            },
            {
              keyword: 'over ear headphones',
              search_volume: 'high',
              competition: 'medium',
              priority: 'secondary'
            }
          ],
          title_patterns: {
            successful_patterns: [
              '[Brand] [Model] Wireless Noise Cancelling Headphones - [Key Feature]',
              '[Product Type] - [Primary Benefit] - [Brand/Model]',
              '[Brand] Bluetooth Headphones with [Feature 1] and [Feature 2]'
            ],
            elements_to_include: ['Brand', 'Key technology', 'Primary benefit', 'Form factor'],
            elements_to_avoid: ['ALL CAPS', 'Excessive punctuation!!!', 'Emoji overuse'],
            optimal_length: '60-80 characters for Amazon, 70-100 for Shopify'
          },
          feature_emphasis: {
            must_highlight: [
              'Noise cancellation technology',
              'Battery life hours',
              'Bluetooth version',
              'Comfort features',
              'Sound quality indicators'
            ],
            differentiation_opportunities: [
              'Multipoint connectivity',
              'Fast charging capability',
              'Premium materials',
              'Extended warranty',
              'Included accessories'
            ]
          },
          price_insights: {
            price_ranges: {
              budget: '$30-80',
              mid_range: '$80-200',
              premium: '$200-400',
              luxury: '$400+'
            },
            competitive_positioning: 'Premium segment $250-350',
            price_sensitivity: 'Medium - buyers research before purchase',
            pricing_strategy: 'Position at $299 with occasional $50 discount'
          },
          successful_listing_elements: [
            'High-quality product photography (5+ images)',
            'Detailed bullet points (5-7 points)',
            'Trust indicators (warranty, certifications)',
            'Customer review highlights in description',
            'Clear compatibility information',
            'Comparison with previous models',
            'Video demonstrations when possible'
          ],
          common_mistakes: [
            'Generic titles without specific features',
            'Missing key specifications (battery life, weight)',
            'Poor image quality or insufficient angles',
            'Overly technical language without benefits',
            'No size/fit information',
            'Lack of use case descriptions'
          ],
          seasonal_insights: {
            peak_seasons: ['Back to school (Aug-Sep)', 'Holiday shopping (Nov-Dec)', 'Prime Day (July)'],
            messaging_angles: {
              summer: 'Travel companion, workout gear',
              fall: 'Back to work/school, productivity',
              winter: 'Holiday gifts, indoor entertainment',
              spring: 'Upgrade season, new tech'
            }
          },
          recommended_keywords: [
            'active noise cancelling',
            'premium wireless headphones',
            'long battery life',
            'comfortable over ear',
            'high fidelity audio',
            'bluetooth 5.0',
            'foldable headphones',
            'travel headphones',
            'work from home headset',
            'audiophile headphones'
          ],
          seo_optimization_tips: [
            'Include brand name in title for branded searches',
            'Use "noise cancelling" vs "noise canceling" (both spellings)',
            'Add material mentions (leather, metal) for quality signals',
            'Include use cases in description (travel, work, gaming)',
            'Target long-tail keywords in bullet points'
          ]
        }
      end
    end
  end
end
