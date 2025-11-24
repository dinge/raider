# frozen_string_literal: true

require 'test_helper'

module Raider
  module Apps
    class ProductListingOptimizationTest < Minitest::Test
      def test_app_class_exists
        assert defined?(Raider::Apps::ProductListingOptimization),
               'ProductListingOptimization app class should be defined'
      end

      def test_app_has_optimize_method
        assert Raider::Apps::ProductListingOptimization.respond_to?(:optimize),
               'App should have .optimize class method'
      end

      def test_task_classes_exist
        assert defined?(Raider::Tasks::AnalyzeProductImages),
               'AnalyzeProductImages task should exist'
        assert defined?(Raider::Tasks::ResearchCompetitors),
               'ResearchCompetitors task should exist'
        assert defined?(Raider::Tasks::OptimizeSeo),
               'OptimizeSeo task should exist'
        assert defined?(Raider::Tasks::GenerateAbVariants),
               'GenerateAbVariants task should exist'
        assert defined?(Raider::Tasks::CalculateQualityScore),
               'CalculateQualityScore task should exist'
      end

      def test_tasks_inherit_from_base
        assert Raider::Tasks::AnalyzeProductImages.ancestors.include?(Raider::Tasks::Base),
               'AnalyzeProductImages should inherit from Base'
        assert Raider::Tasks::ResearchCompetitors.ancestors.include?(Raider::Tasks::Base),
               'ResearchCompetitors should inherit from Base'
        assert Raider::Tasks::OptimizeSeo.ancestors.include?(Raider::Tasks::Base),
               'OptimizeSeo should inherit from Base'
        assert Raider::Tasks::GenerateAbVariants.ancestors.include?(Raider::Tasks::Base),
               'GenerateAbVariants should inherit from Base'
        assert Raider::Tasks::CalculateQualityScore.ancestors.include?(Raider::Tasks::Base),
               'CalculateQualityScore should inherit from Base'
      end

      def test_tasks_have_required_methods
        [
          Raider::Tasks::AnalyzeProductImages,
          Raider::Tasks::ResearchCompetitors,
          Raider::Tasks::OptimizeSeo,
          Raider::Tasks::GenerateAbVariants,
          Raider::Tasks::CalculateQualityScore
        ].each do |task_class|
          assert task_class.instance_methods.include?(:process),
                 "#{task_class} should have process method"
          assert task_class.instance_methods.include?(:system_prompt),
                 "#{task_class} should have system_prompt method"
          assert task_class.instance_methods.include?(:prompt),
                 "#{task_class} should have prompt method"
          assert task_class.instance_methods.include?(:example_response_struct),
                 "#{task_class} should have example_response_struct method"
        end
      end

      def test_analyze_product_images_response_structure
        task_class = Raider::Tasks::AnalyzeProductImages
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:product_identification), 'Response should include product_identification'
        assert struct.key?(:key_features), 'Response should include key_features'
        assert struct.key?(:visual_quality), 'Response should include visual_quality'
        assert struct.key?(:selling_points), 'Response should include selling_points'
        assert struct.key?(:target_audience), 'Response should include target_audience'
      end

      def test_research_competitors_response_structure
        task_class = Raider::Tasks::ResearchCompetitors
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:category_analysis), 'Response should include category_analysis'
        assert struct.key?(:top_keywords), 'Response should include top_keywords'
        assert struct.key?(:title_patterns), 'Response should include title_patterns'
        assert struct.key?(:price_insights), 'Response should include price_insights'
      end

      def test_optimize_seo_response_structure
        task_class = Raider::Tasks::OptimizeSeo
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:title), 'Response should include title'
        assert struct.key?(:description), 'Response should include description'
        assert struct.key?(:bullet_points), 'Response should include bullet_points'
        assert struct.key?(:keywords), 'Response should include keywords'

        # Verify data types
        assert struct[:title].is_a?(String), 'Title should be a string'
        assert struct[:bullet_points].is_a?(Array), 'Bullet points should be an array'
        assert struct[:keywords].is_a?(Array), 'Keywords should be an array'
      end

      def test_generate_ab_variants_response_structure
        task_class = Raider::Tasks::GenerateAbVariants
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:variants), 'Response should include variants'
        assert struct[:variants].is_a?(Array), 'Variants should be an array'
        assert struct[:variants].length >= 3, 'Should have at least 3 variants'

        first_variant = struct[:variants].first
        assert first_variant.key?(:variant_id), 'Variant should have variant_id'
        assert first_variant.key?(:title), 'Variant should have title'
        assert first_variant.key?(:hypothesis), 'Variant should have hypothesis'
      end

      def test_calculate_quality_score_response_structure
        task_class = Raider::Tasks::CalculateQualityScore
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:overall_score), 'Response should include overall_score'
        assert struct.key?(:category_scores), 'Response should include category_scores'
        assert struct.key?(:strengths), 'Response should include strengths'
        assert struct.key?(:improvements), 'Response should include improvements'

        # Verify score is in valid range
        assert struct[:overall_score].between?(1, 100), 'Overall score should be 1-100'
        assert struct[:strengths].is_a?(Array), 'Strengths should be an array'
        assert struct[:improvements].is_a?(Array), 'Improvements should be an array'
      end

      def test_app_generate_summary_method
        seo_content = {
          title: 'Test Product Title',
          description: 'Test description',
          bullet_points: ['Feature 1', 'Feature 2'],
          keywords: ['keyword1', 'keyword2']
        }

        quality_score = {
          overall_score: 85,
          strengths: ['Good SEO'],
          improvements: ['Add more images']
        }

        ab_variants = {
          variants: [{}, {}, {}]
        }

        summary = Raider::Apps::ProductListingOptimization.generate_summary(
          seo_content,
          quality_score,
          ab_variants
        )

        assert summary.is_a?(String), 'Summary should be a string'
        assert summary.include?('Test Product Title'), 'Summary should include title'
        assert summary.include?('85/100'), 'Summary should include quality score'
      end
    end
  end
end
