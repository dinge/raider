# frozen_string_literal: true

module Raider
  module Tasks
    class CalculateQualityScore < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          You are a product listing quality auditor with expertise in e-commerce optimization.
          You evaluate listings against proven best practices that drive conversions and search rankings.

          Your evaluation framework considers:
          - Content Quality: Completeness, clarity, persuasiveness
          - SEO Optimization: Keyword usage, searchability, discoverability
          - Visual Quality: Image quality, quantity, angles
          - Information Architecture: Structure, scannability, hierarchy
          - Conversion Elements: Trust signals, urgency, value prop
          - Competitive Positioning: How it stacks up vs competitors

          You provide:
          1. Objective scores based on measurable criteria
          2. Specific, actionable improvement recommendations
          3. Prioritized fixes (high impact first)
          4. Realistic assessment of competitive positioning
          5. Expected impact of improvements

          Your audits consistently identify opportunities that yield 20-50% conversion lifts.
        SYSTEM
      end

      def prompt
        # Gather all the context
        image_analysis = @inputs[:image_analysis]
        seo_content = @inputs[:seo_content]
        ab_variants = @inputs[:ab_variants]
        competitor_research = @inputs[:competitor_research]

        listing_summary = if seo_content
                           "Title: #{seo_content[:title]}\n" \
                           "Description Length: #{seo_content[:description]&.length || 0} characters\n" \
                           "Bullet Points: #{seo_content[:bullet_points]&.length || 0}\n" \
                           "Keywords: #{seo_content[:keywords]&.length || 0}"
                         else
                           "Listing incomplete"
                         end

        image_quality = image_analysis&.dig(:visual_quality, :overall_quality) || 'unknown'
        image_count = if @input.is_a?(Array)
                       @input.length
                     else
                       1
                     end

        competitive_level = competitor_research&.dig(:category_analysis, :competition_level) || 'unknown'

        <<~TEXT
          Evaluate this product listing and assign a quality score from 1-100.

          **Listing Overview:**
          #{listing_summary}

          **Image Quality:** #{image_quality}
          **Image Count:** #{image_count}
          **Competition Level:** #{competitive_level}

          **Full Content:**
          Title: #{seo_content[:title]}
          Description: #{seo_content[:description]&.truncate(300)}
          Bullet Points: #{seo_content[:bullet_points]&.map { |bp| "- #{bp}" }&.join("\n")}

          Evaluate across these dimensions (score each 1-100):

          1. **Title Quality** (20 points)
             - Keyword optimization
             - Length (60-80 chars ideal)
             - Compelling and clear
             - Follows best practices

          2. **Description Quality** (20 points)
             - Engaging opening
             - Benefit-focused
             - Addresses objections
             - Natural keyword inclusion
             - Appropriate length (150-250 words)

          3. **Bullet Points** (20 points)
             - Benefit-driven
             - Scannable and clear
             - Covers key features
             - 5-7 bullets optimal
             - Formatting and readability

          4. **SEO Optimization** (15 points)
             - Keyword coverage (20+ relevant keywords)
             - Primary keyword placement
             - Long-tail keyword inclusion
             - Search intent alignment

          5. **Visual Content** (15 points)
             - Image quality
             - Number of images (5+ ideal)
             - Variety of angles
             - Lifestyle images included
             - Professional presentation

          6. **Competitive Positioning** (10 points)
             - Unique value proposition
             - Differentiation from competitors
             - Price-value perception
             - Market positioning clarity

          Provide:
          - Overall score (1-100)
          - Score breakdown by category
          - Top 5 strengths
          - Top 5 improvement areas (prioritized by impact)
          - Expected conversion rate vs industry average
          - Quick wins (changes that take <5 minutes but boost score)

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          overall_score: 87,
          grade: 'A',
          category_scores: {
            title_quality: 92,
            description_quality: 88,
            bullet_points: 85,
            seo_optimization: 90,
            visual_content: 80,
            competitive_positioning: 87
          },
          strengths: [
            'Excellent title optimization - front-loads primary keyword while remaining natural',
            'Strong benefit-focused bullet points that address multiple buyer motivations',
            'Comprehensive keyword coverage with 25 relevant terms including long-tail',
            'Compelling emotional hooks in description that create desire',
            'Clear unique value proposition differentiates from generic competitors'
          ],
          improvements: [
            {
              area: 'Visual Content',
              issue: 'Only 3 product images - competitors average 6-8 images',
              recommendation: 'Add lifestyle images showing product in use, size comparison, and close-up details',
              impact: 'high',
              effort: 'medium',
              expected_lift: '15-25% conversion increase'
            },
            {
              area: 'Description',
              issue: 'Missing specific dimensions and weight',
              recommendation: 'Add exact measurements in both imperial and metric',
              impact: 'medium',
              effort: 'low',
              expected_lift: '5-10% reduction in questions/returns'
            },
            {
              area: 'Trust Signals',
              issue: 'No warranty or guarantee mentioned',
              recommendation: 'Highlight 2-year warranty and 30-day return policy prominently',
              impact: 'medium',
              effort: 'low',
              expected_lift: '8-12% conversion boost for risk-averse buyers'
            },
            {
              area: 'Bullet Points',
              issue: 'Bullet #4 is slightly generic compared to others',
              recommendation: 'Replace with specific technical spec or customer benefit',
              impact: 'low',
              effort: 'low',
              expected_lift: '2-3% improvement'
            },
            {
              area: 'SEO',
              issue: 'Missing common misspelling variations',
              recommendation: 'Add "noise canceling" (one L) to keyword list',
              impact: 'low',
              effort: 'low',
              expected_lift: 'Capture additional 5% of search traffic'
            }
          ],
          quick_wins: [
            'Add "2-Year Warranty" badge to title (+3 score points)',
            'Include exact dimensions in first bullet point (+2 points)',
            'Add "Free Shipping" if applicable (+2 points)',
            'Change description opening to question format for engagement (+1 point)',
            'Add compatibility note ("Works with iPhone, Android, PC") (+1 point)'
          ],
          competitive_analysis: {
            vs_category_average: '+32 points',
            vs_top_performers: '-13 points',
            market_position: 'Upper quartile - strong listing that will convert well',
            ranking_potential: 'Expected to rank in top 20% of category search results'
          },
          conversion_predictions: {
            current_listing: {
              expected_cvr: '3.2-3.8%',
              vs_category: 'Above average (category avg: 2.1%)',
              confidence: 'high'
            },
            with_improvements: {
              expected_cvr: '4.1-4.7%',
              potential_lift: '25-30%',
              confidence: 'medium'
            }
          },
          readability: {
            reading_level: 'Grade 8 (ideal for broad audience)',
            sentence_complexity: 'Appropriate - mix of simple and compound',
            jargon_level: 'Minimal - accessible to general consumers'
          },
          next_optimization_steps: [
            'Implement top 3 improvements',
            'Launch A/B test with variants',
            'Monitor conversion rate for 2 weeks',
            'Analyze which variant performs best',
            'Iterate based on data',
            'Add video demonstration if budget allows'
          ],
          estimated_roi: {
            time_investment: '2-3 hours for all improvements',
            expected_revenue_lift: '25-30% over 90 days',
            roi_multiple: '50x+ (assuming typical ad spend/listing)'
          }
        }
      end
    end
  end
end
