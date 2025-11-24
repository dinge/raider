# frozen_string_literal: true

module Raider
  module Tasks
    class GenerateAbVariants < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          You are an A/B testing specialist and conversion rate optimization expert for e-commerce.
          You understand that different messaging resonates with different customer segments and that
          testing is the only way to know what truly works.

          Your expertise includes:
          - Creating meaningful variations that test specific hypotheses
          - Understanding different customer psychographics and triggers
          - Balancing creativity with statistical validity
          - Designing tests that will yield actionable insights
          - Knowing which elements have the highest impact on conversion

          When creating variants, you ensure:
          1. Each variant tests a clear hypothesis
          2. Variations are different enough to matter
          3. All variants maintain SEO optimization
          4. Changes are tracked for learning
          5. Recommendations are data-driven

          Your variants consistently reveal insights that boost conversions by 15-30%.
        SYSTEM
      end

      def prompt
        original_content = @inputs[:seo_content]
        product_info = @inputs[:image_analysis]

        original_title = original_content[:title] || 'No title provided'
        original_description = original_content[:description] || 'No description provided'
        original_bullets = original_content[:bullet_points] || []

        <<~TEXT
          Create 3 distinct A/B test variants of the product listing to test different conversion hypotheses.

          **Original Listing (Control):**
          Title: #{original_title}

          Description: #{original_description&.truncate(200)}

          Bullet Points:
          #{original_bullets&.map { |bp| "- #{bp}" }&.join("\n")}

          **Product Context:**
          #{product_info&.dig(:product_identification, :product_type) || @input}

          Create 3 variants that test:

          **Variant A: Feature-Focused**
          - Hypothesis: Technical buyers want specifications upfront
          - Emphasize technical specs, measurements, certifications
          - More detailed, specification-heavy language
          - Appeals to analytical, research-oriented buyers

          **Variant B: Benefit-Focused**
          - Hypothesis: Emotional buyers want outcomes and lifestyle
          - Emphasize benefits, transformations, experiences
          - More aspirational, outcome-oriented language
          - Appeals to emotional, quick-decision buyers

          **Variant C: Social Proof-Focused**
          - Hypothesis: Risk-averse buyers want validation
          - Emphasize customer reviews, testimonials, popularity
          - Include social proof elements throughout
          - Appeals to cautious, validation-seeking buyers

          For each variant, provide:
          1. Modified title (testing a different angle)
          2. Modified first 2 bullet points (different emphasis)
          3. Test hypothesis being evaluated
          4. Expected customer segment this will appeal to
          5. What you'll learn from testing this variant

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          variants: [
            {
              variant_id: 'A',
              name: 'Feature-Focused (Technical Buyers)',
              title: 'Sony WH-1000XM5: Advanced ANC Processor, 40mm Drivers, 30Hr USB-C Battery, Bluetooth 5.2 Multipoint',
              bullet_points: [
                '🔧 ADVANCED TECHNOLOGY: HD Noise Cancelling Processor QN1 with 8 microphones and dual feedback system captures and cancels 99% of ambient frequencies (20Hz-20kHz)',
                '📊 TECHNICAL SPECS: 40mm neodymium drivers, 4-40kHz frequency response, LDAC/AAC/SBC codec support, 660mAh battery, 250g weight, Bluetooth 5.2'
              ],
              hypothesis: 'Technical specifications and detailed features will appeal to analytical buyers who research before purchasing',
              target_segment: 'Tech enthusiasts, audiophiles, engineers, detail-oriented professionals',
              learning_objective: 'Determine if technical depth increases conversion for research-heavy buyers',
              expected_impact: 'Higher conversion for informed buyers, lower bounce rate from specs-seekers'
            },
            {
              variant_id: 'B',
              name: 'Benefit-Focused (Lifestyle Buyers)',
              title: 'Sony WH-1000XM5: Your Personal Silence Sanctuary - Focus Better, Travel Easier, Live Fuller',
              bullet_points: [
                '✨ RECLAIM YOUR FOCUS: Eliminate distractions and enter your zone of peak productivity - finish projects faster, enjoy music deeper, meditate anywhere',
                '🌍 TRANSFORM YOUR COMMUTE: Turn stressful travels into peaceful me-time - arrive refreshed, not drained, whether flying cross-country or riding the subway'
              ],
              hypothesis: 'Emotional benefits and lifestyle transformation will resonate with aspiration-driven buyers',
              target_segment: 'Busy professionals, frequent travelers, lifestyle-focused consumers',
              learning_objective: 'Test if outcome-based messaging increases impulse purchases',
              expected_impact: 'Higher conversion for time-poor buyers, increased average order value'
            },
            {
              variant_id: 'C',
              name: 'Social Proof-Focused (Validation Seekers)',
              title: 'Sony WH-1000XM5: #1 Rated by 50,000+ Reviews - Trusted by Professionals, Loved by Audiophiles',
              bullet_points: [
                '⭐ OVERWHELMINGLY RECOMMENDED: Join 50,000+ five-star reviewers who call these "life-changing" and "worth every penny" - rated Best Overall by Wirecutter, Forbes, and CNET',
                '🏆 AWARD-WINNING PERFORMANCE: Winner of 25+ industry awards including CES Innovation Award - chosen by Fortune 500 companies for their employees\' WFH setups'
              ],
              hypothesis: 'Social proof and validation signals will reduce purchase anxiety and increase trust',
              target_segment: 'Risk-averse buyers, first-time premium buyers, gift shoppers',
              learning_objective: 'Measure impact of social proof on conversion and return rates',
              expected_impact: 'Higher trust scores, lower cart abandonment, increased repeat purchases'
            }
          ],
          test_recommendations: {
            sample_size_needed: 'Minimum 100 conversions per variant for 95% confidence',
            test_duration: '2-4 weeks or until statistical significance',
            primary_metric: 'Conversion rate (add to cart)',
            secondary_metrics: ['Click-through rate', 'Time on page', 'Bounce rate', 'Average order value'],
            segment_analysis: 'Break down results by traffic source, device type, and new vs returning visitors'
          },
          hypothesis_priorities: [
            {
              hypothesis: 'Emotional benefits drive more impulse purchases than technical specs',
              test: 'Variant B vs Control',
              priority: 'high',
              rationale: 'Most e-commerce research shows benefit-focused copy converts better'
            },
            {
              hypothesis: 'Social proof reduces purchase anxiety for premium products',
              test: 'Variant C vs Control',
              priority: 'high',
              rationale: 'Premium price point increases risk perception, social proof counters this'
            },
            {
              hypothesis: 'Technical buyers are underserved by generic marketing',
              test: 'Variant A vs Control',
              priority: 'medium',
              rationale: 'Worth testing for potential segment-specific landing pages'
            }
          ],
          next_iterations: [
            'Test different price presentation formats',
            'Experiment with urgency elements (limited stock, sale countdown)',
            'Try different primary image angles',
            'Test longer vs shorter bullet points',
            'Experiment with video vs image-only listings'
          ]
        }
      end
    end
  end
end
