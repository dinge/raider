# frozen_string_literal: true

module Raider
  module Apps
    class ProductListingOptimization < Base
      def self.optimize(input:, inputs: {}, with_app_persistence: false, with_auto_context: false)
        new(
          with_app_persistence:,
          with_auto_context:,
          with_vcr: true,
          input:,
          inputs:,
          on_task_create: :show_task_start,
          llm: :gpt5_mini
        ).tap do |app|
          app.agents.optimize_listing(input:) do |ag|
            # Step 1: Analyze product images for visual features
            image_analysis = ag.tasks.analyze_product_images(input:, inputs:)

            # Step 2: Research competitors (optional - can be skipped if no category provided)
            competitor_research = if inputs[:category].present? || inputs[:keywords].present?
                                    ag.tasks.research_competitors(
                                      input: inputs[:category] || inputs[:keywords],
                                      inputs: { image_analysis: }
                                    )
                                  else
                                    { competitive_insights: 'No category provided - skipped competitor research' }
                                  end

            # Step 3: Generate SEO-optimized content
            seo_content = ag.tasks.optimize_seo(
              input:,
              inputs: {
                image_analysis:,
                competitor_research:,
                category: inputs[:category],
                target_audience: inputs[:target_audience],
                brand_voice: inputs[:brand_voice]
              }
            )

            # Step 4: Generate A/B test variants
            ab_variants = ag.tasks.generate_ab_variants(
              input:,
              inputs: {
                seo_content:,
                image_analysis:
              }
            )

            # Step 5: Calculate overall quality score
            quality_score = ag.tasks.calculate_quality_score(
              input:,
              inputs: {
                image_analysis:,
                seo_content:,
                ab_variants:,
                competitor_research:
              }
            )

            # Add structured outputs
            ag.add_to_output!(
              outputs: {
                optimized_listing: {
                  title: seo_content[:title],
                  description: seo_content[:description],
                  bullet_points: seo_content[:bullet_points],
                  keywords: seo_content[:keywords]
                },
                image_analysis:,
                ab_variants:,
                quality_score:,
                competitor_insights: competitor_research,
                metadata: inputs
              }
            )

            # Add human-readable summary
            summary = generate_summary(seo_content, quality_score, ab_variants)
            ag.add_to_output!(output: summary)
          end
        end
      end

      def self.generate_summary(seo_content, quality_score, ab_variants)
        <<~SUMMARY
          # Product Listing Optimization Results

          ## Optimized Title
          #{seo_content[:title]}

          ## Quality Score: #{quality_score[:overall_score]}/100

          ### Strengths
          #{quality_score[:strengths]&.map { |s| "- #{s}" }&.join("\n")}

          ### Improvement Areas
          #{quality_score[:improvements]&.map { |i| "- #{i}" }&.join("\n")}

          ## Description
          #{seo_content[:description]}

          ## Key Features (Bullet Points)
          #{seo_content[:bullet_points]&.map { |bp| "• #{bp}" }&.join("\n")}

          ## SEO Keywords (#{seo_content[:keywords]&.length || 0} keywords)
          #{seo_content[:keywords]&.join(', ')}

          ## A/B Testing Variants Available: #{ab_variants[:variants]&.length || 0}

          Ready to boost your conversions! 🚀
        SUMMARY
      end

      def show_task_start(task)
        Raider.log(task_started: task.ident)
      end
    end
  end
end
