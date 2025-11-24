# frozen_string_literal: true

module Raider
  module Tasks
    class OptimizeSeo < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          You are a world-class e-commerce copywriter and SEO expert specializing in product listings
          that convert browsers into buyers. You combine:
          - Persuasive copywriting that triggers buying decisions
          - SEO expertise for maximum organic visibility
          - Understanding of marketplace algorithms (Amazon A9, Google Shopping)
          - Consumer psychology and decision-making triggers
          - Data-driven optimization based on conversion patterns

          Your listings consistently outperform competitors because you:
          1. Front-load key information in titles
          2. Write benefit-focused, not feature-focused copy
          3. Use power words and emotional triggers appropriately
          4. Optimize for both humans and search algorithms
          5. Create urgency and value perception
          6. Maintain brand voice while maximizing conversions

          Write clear, compelling copy that sells while ranking high in search results.
        SYSTEM
      end

      def prompt
        # Gather context from previous tasks
        product_info = @inputs[:image_analysis]
        competitor_insights = @inputs[:competitor_research]

        product_summary = if product_info
                           "Product: #{product_info[:product_identification][:product_type]}\n" \
                           "Key Features: #{product_info[:key_features]&.join(', ')}\n" \
                           "Target Audience: #{product_info[:target_audience][:primary]}\n" \
                           "USPs: #{product_info[:unique_selling_propositions]&.join(', ')}"
                         else
                           "Product description: #{@input}"
                         end

        competitive_context = if competitor_insights && competitor_insights[:recommended_keywords]
                               "Top Keywords to Target: #{competitor_insights[:recommended_keywords]&.take(10)&.join(', ')}\n" \
                               "Successful Title Pattern: #{competitor_insights.dig(:title_patterns, :successful_patterns)&.first}"
                             else
                               ""
                             end

        brand_voice = @inputs[:brand_voice] || 'professional and trustworthy'
        target_audience = @inputs[:target_audience] || product_info&.dig(:target_audience, :primary) || 'general consumers'
        category = @inputs[:category] || product_info&.dig(:product_identification, :category) || 'general'

        <<~TEXT
          Create an optimized product listing that will drive conversions and rank well in search.

          #{product_summary}

          #{competitive_context}

          Brand Voice: #{brand_voice}
          Target Audience: #{target_audience}
          Category: #{category}

          Generate a complete, optimized listing with:

          1. **Title** (60-80 characters):
             - Front-load primary keyword
             - Include brand, key feature, and main benefit
             - Use power words that increase click-through
             - Natural, not keyword-stuffed

          2. **Description** (150-200 words):
             - Opening hook that captures attention
             - Paint the picture of life with this product
             - Address key objections/concerns
             - Create desire and urgency
             - End with clear value proposition
             - SEO-optimized but reads naturally

          3. **Bullet Points** (exactly 5):
             - Start each with a benefit, not just a feature
             - Use formatting: ALL CAPS for key words sparingly
             - Include specifications where relevant
             - Each 1-2 lines maximum
             - Address different buyer motivations

          4. **Keywords** (20-25 relevant keywords):
             - Mix of high-volume and long-tail
             - Include common misspellings if relevant
             - Category-specific terms
             - Benefit-focused keywords
             - Use case keywords

          Focus on BENEFITS over features. Show, don't tell. Create emotional connection.

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          title: 'Sony WH-1000XM5 Noise Cancelling Wireless Headphones - Premium Sound, 30Hr Battery, Multipoint Connect',
          description: 'Transform your daily commute, work sessions, and travel with the Sony WH-1000XM5 - the ultimate wireless headphones for professionals who demand the best. Industry-leading noise cancellation creates your personal oasis of silence, whether you\'re in a busy office, airplane, or coffee shop. Premium comfort meets exceptional sound quality: luxurious leather ear cushions and precision-tuned 40mm drivers deliver crystal-clear audio for 30 hours straight. Multipoint Bluetooth connectivity lets you seamlessly switch between your laptop, phone, and tablet without missing a beat. The intelligent design automatically adjusts noise cancellation based on your environment, while touch controls put complete command at your fingertips. Foldable design and included carrying case make these your perfect travel companion. Upgrade to the headphones that over 50,000 five-star reviewers call "life-changing" - with a 2-year warranty and 30-day money-back guarantee, experience the difference risk-free.',
          bullet_points: [
            '🎧 UNMATCHED NOISE CANCELLATION: Industry-leading ANC technology blocks 99% of ambient noise - create your personal sanctuary anywhere, from crowded airports to noisy offices',
            '⚡ ALL-DAY POWER: 30-hour battery life with quick charge (10 min = 5 hours) means your music never stops, perfect for long flights, workdays, or marathon study sessions',
            '📱 SEAMLESS CONNECTIVITY: Multipoint Bluetooth 5.2 connects to two devices simultaneously - switch instantly between laptop calls and phone music without reconnecting',
            '🏆 PREMIUM COMFORT: Plush memory foam ear cushions and lightweight 250g design for hours of comfortable wear - engineered for all-day professionals and audiophiles',
            '🎵 AUDIOPHILE SOUND QUALITY: 40mm drivers with LDAC support deliver Hi-Res audio that brings your favorite music to life - hear details you\'ve been missing'
          ],
          keywords: [
            'noise cancelling headphones',
            'wireless bluetooth headphones',
            'sony headphones',
            'over ear headphones',
            'noise canceling headphones wireless',
            'premium headphones',
            'work from home headset',
            'travel headphones',
            'active noise cancelling',
            'long battery life headphones',
            'comfortable headphones',
            'multipoint bluetooth headphones',
            'professional headphones',
            'audiophile headphones',
            'foldable headphones',
            'wireless headset with microphone',
            'commuter headphones',
            'office headphones',
            'study headphones',
            'gym workout headphones',
            'airplane travel headphones',
            'sony wh1000xm5',
            'noise cancellation technology',
            'hi res audio headphones',
            'bluetooth 5.2 headphones'
          ],
          seo_metadata: {
            primary_keyword: 'noise cancelling headphones',
            secondary_keywords: ['wireless bluetooth headphones', 'sony headphones'],
            title_length: 95,
            description_word_count: 182,
            keyword_density: 'optimized',
            readability_score: 'easy to read'
          },
          writing_analysis: {
            tone: 'Professional yet aspirational',
            persuasion_techniques: ['Social proof', 'Risk reversal', 'Benefit stacking', 'Emotional triggers'],
            target_buyer_stage: 'Consideration/Decision',
            estimated_conversion_lift: '25-40% vs generic listing'
          }
        }
      end
    end
  end
end
