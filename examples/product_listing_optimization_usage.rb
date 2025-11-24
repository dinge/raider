#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of the Product Listing Optimization app
#
# This script demonstrates how to use the ProductListingOptimization app
# to create optimized e-commerce listings from product images.
#
# Usage:
#   ruby examples/product_listing_optimization_usage.rb

require_relative '../lib/raider'

# Enable debug logging to see detailed execution
Raider.logger.level = Logger::INFO

puts "=" * 80
puts "Product Listing Optimization - Example Usage"
puts "=" * 80
puts

# Example 1: Basic optimization with single image
puts "\n" + "=" * 80
puts "Example 1: Basic Single Image Optimization"
puts "=" * 80

result1 = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product_image.jpg',
  inputs: {
    category: 'wireless headphones'
  }
)

puts "\n📊 Results:"
puts "\nOptimized Title:"
puts "  #{result1.outputs[:seo_content][:title]}"

puts "\nQuality Score: #{result1.outputs[:quality_score][:overall_score]}/100"
puts "Grade: #{result1.outputs[:quality_score][:grade]}"

puts "\nTop 3 Keywords:"
result1.outputs[:seo_content][:keywords].take(3).each { |kw| puts "  • #{kw}" }

# Example 2: Multiple images with detailed inputs
puts "\n" + "=" * 80
puts "Example 2: Multiple Images with Brand Voice"
puts "=" * 80

result2 = Raider::Apps::ProductListingOptimization.optimize(
  input: [
    'path/to/product_front.jpg',
    'path/to/product_side.jpg',
    'path/to/product_detail.jpg'
  ],
  inputs: {
    category: 'kitchen appliances',
    brand_voice: 'modern and innovative',
    target_audience: 'home cooks and culinary enthusiasts',
    price_point: '$299'
  }
)

puts "\n📊 Results:"
puts "\nOptimized Description (first 200 chars):"
puts "  #{result2.outputs[:seo_content][:description][0..200]}..."

puts "\nBullet Points:"
result2.outputs[:seo_content][:bullet_points].each do |bullet|
  puts "  • #{bullet[0..80]}..."
end

# Example 3: Accessing A/B test variants
puts "\n" + "=" * 80
puts "Example 3: A/B Test Variants"
puts "=" * 80

result3 = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product.jpg',
  inputs: {
    category: 'fitness equipment'
  }
)

puts "\n🧪 A/B Test Variants:"
result3.outputs[:ab_variants][:variants].each do |variant|
  puts "\n#{variant[:name]} (#{variant[:variant_id]})"
  puts "  Hypothesis: #{variant[:hypothesis]}"
  puts "  Target: #{variant[:target_segment]}"
  puts "  Title: #{variant[:title][0..80]}..."
end

# Example 4: Quality score analysis
puts "\n" + "=" * 80
puts "Example 4: Quality Score Analysis"
puts "=" * 80

result4 = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product.jpg',
  inputs: {
    category: 'electronics'
  }
)

quality = result4.outputs[:quality_score]

puts "\n📈 Quality Breakdown:"
quality[:category_scores].each do |category, score|
  puts "  #{category.to_s.titleize}: #{score}/100"
end

puts "\n💪 Top Strengths:"
quality[:strengths].take(3).each_with_index do |strength, i|
  puts "  #{i + 1}. #{strength[0..100]}..."
end

puts "\n🎯 Priority Improvements:"
quality[:improvements].take(3).each_with_index do |improvement, i|
  puts "\n  #{i + 1}. #{improvement[:area]} (Impact: #{improvement[:impact].upcase})"
  puts "     Issue: #{improvement[:issue]}"
  puts "     Fix: #{improvement[:recommendation][0..80]}..."
  puts "     Expected: #{improvement[:expected_lift]}"
end

puts "\n⚡ Quick Wins:"
quality[:quick_wins].each { |win| puts "  • #{win}" }

# Example 5: Competitive intelligence
puts "\n" + "=" * 80
puts "Example 5: Competitive Intelligence"
puts "=" * 80

result5 = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product.jpg',
  inputs: {
    category: 'home office furniture'
  }
)

research = result5.outputs[:competitor_research]

puts "\n🔍 Category Analysis:"
puts "  Competition Level: #{research[:category_analysis][:competition_level]}"
puts "  Market Saturation: #{research[:category_analysis][:market_saturation]}"

puts "\n💰 Price Positioning:"
research[:price_insights][:price_ranges].each do |tier, range|
  puts "  #{tier.to_s.titleize}: #{range}"
end

puts "\n🔑 Top Keywords (by priority):"
research[:top_keywords].take(5).each do |kw|
  puts "  • #{kw[:keyword]} (#{kw[:priority]}, volume: #{kw[:search_volume]})"
end

puts "\n📋 Successful Title Patterns:"
research[:title_patterns][:successful_patterns].take(2).each do |pattern|
  puts "  • #{pattern}"
end

# Example 6: With app persistence (for production use)
puts "\n" + "=" * 80
puts "Example 6: With Database Persistence"
puts "=" * 80

result6 = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product.jpg',
  inputs: {
    category: 'outdoor gear'
  },
  with_app_persistence: true  # Saves results to database
)

puts "\n💾 Persisted Results:"
puts "  App Ident: #{result6.app_ident}"
puts "  Can retrieve later with: Raider::App.find_by(ident: '#{result6.app_ident}')"

# Example 7: Accessing product analysis details
puts "\n" + "=" * 80
puts "Example 7: Product Analysis Details"
puts "=" * 80

result7 = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product.jpg',
  inputs: {
    category: 'smart home devices'
  }
)

analysis = result7.outputs[:image_analysis]

puts "\n🔬 Product Analysis:"
puts "\nIdentification:"
puts "  Product Type: #{analysis[:product_identification][:product_type]}"
puts "  Category: #{analysis[:product_identification][:category]}"
puts "  Brand: #{analysis[:product_identification][:brand]}"

puts "\nKey Features:"
analysis[:key_features].take(5).each { |feature| puts "  • #{feature}" }

puts "\nTarget Audience:"
puts "  Primary: #{analysis[:target_audience][:primary]}"
puts "  Secondary: #{analysis[:target_audience][:secondary]}"
puts "  Demographics: #{analysis[:target_audience][:demographics]}"

puts "\nUnique Selling Propositions:"
analysis[:unique_selling_propositions].each { |usp| puts "  • #{usp}" }

puts "\nVisual Quality:"
puts "  Overall: #{analysis[:visual_quality][:overall_quality]}"
puts "  Professional Score: #{analysis[:visual_quality][:professional_score]}/10"
puts "  Improvements: #{analysis[:visual_quality][:improvement_suggestions].join(', ')}"

# Example 8: Custom workflow with manual agent control
puts "\n" + "=" * 80
puts "Example 8: Custom Workflow"
puts "=" * 80

app = Raider::Apps::ProductListingOptimization.new(
  input: 'path/to/product.jpg',
  inputs: {
    category: 'fashion accessories'
  },
  with_vcr: false,  # Make real API calls
  llm: :gpt5_mini
)

result8 = app.agents.optimize_listing(input: app.input) do |ag|
  # Step 1: Analyze images
  puts "\n  → Analyzing product images..."
  image_analysis = ag.tasks.analyze_product_images(
    input: app.input,
    inputs: app.inputs
  )
  puts "    ✓ Identified: #{image_analysis[:product_identification][:product_type]}"

  # Step 2: Research competition
  puts "\n  → Researching competitors..."
  competitor_research = ag.tasks.research_competitors(
    input: app.inputs[:category],
    inputs: { image_analysis: }
  )
  puts "    ✓ Found #{competitor_research[:top_keywords].length} keywords"

  # Step 3: Optimize SEO
  puts "\n  → Optimizing SEO content..."
  seo_content = ag.tasks.optimize_seo(
    input: app.input,
    inputs: {
      image_analysis:,
      competitor_research:,
      category: app.inputs[:category]
    }
  )
  puts "    ✓ Generated title: #{seo_content[:title][0..50]}..."

  # Step 4: Generate variants
  puts "\n  → Generating A/B test variants..."
  ab_variants = ag.tasks.generate_ab_variants(
    input: app.input,
    inputs: {
      seo_content:,
      image_analysis:
    }
  )
  puts "    ✓ Created #{ab_variants[:variants].length} variants"

  # Step 5: Calculate quality
  puts "\n  → Calculating quality score..."
  quality_score = ag.tasks.calculate_quality_score(
    input: app.input,
    inputs: {
      image_analysis:,
      seo_content:,
      ab_variants:,
      competitor_research:
    }
  )
  puts "    ✓ Score: #{quality_score[:overall_score]}/100 (#{quality_score[:grade]})"

  # Store outputs
  ag.add_to_output!(
    outputs: {
      optimized_listing: Raider::Apps::ProductListingOptimization.generate_summary(
        seo_content,
        quality_score,
        ab_variants
      ),
      image_analysis:,
      competitor_research:,
      seo_content:,
      ab_variants:,
      quality_score:
    }
  )
end

puts "\n✅ Custom workflow complete!"

# Example 9: Error handling and validation
puts "\n" + "=" * 80
puts "Example 9: Error Handling"
puts "=" * 80

begin
  result9 = Raider::Apps::ProductListingOptimization.optimize(
    input: 'path/to/product.jpg',
    inputs: {}  # Missing required category
  )
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  puts "   Solution: Always provide 'category' in inputs hash"
end

# Proper error handling
result9 = if File.exist?('path/to/product.jpg')
            Raider::Apps::ProductListingOptimization.optimize(
              input: 'path/to/product.jpg',
              inputs: { category: 'electronics' }
            )
          else
            puts "\n⚠️  Image file not found, skipping optimization"
            nil
          end

# Example 10: Batch processing
puts "\n" + "=" * 80
puts "Example 10: Batch Processing Multiple Products"
puts "=" * 80

products = [
  { image: 'path/to/product1.jpg', category: 'electronics' },
  { image: 'path/to/product2.jpg', category: 'home goods' },
  { image: 'path/to/product3.jpg', category: 'fashion' }
]

puts "\n📦 Processing #{products.length} products..."

results = products.map do |product|
  begin
    result = Raider::Apps::ProductListingOptimization.optimize(
      input: product[:image],
      inputs: { category: product[:category] },
      with_vcr: true  # Use cached responses for speed
    )

    puts "  ✓ #{product[:category]}: Score #{result.outputs[:quality_score][:overall_score]}/100"
    result
  rescue StandardError => e
    puts "  ✗ #{product[:category]}: #{e.message}"
    nil
  end
end

successful = results.compact.length
puts "\n✅ Successfully processed #{successful}/#{products.length} products"

# Summary statistics
if successful > 0
  avg_score = results.compact.sum { |r| r.outputs[:quality_score][:overall_score] } / successful.to_f
  puts "   Average Quality Score: #{avg_score.round(1)}/100"
end

puts "\n" + "=" * 80
puts "Examples complete!"
puts "=" * 80
puts "\nFor more information, see:"
puts "  • Documentation: docs/PRODUCT_LISTING_OPTIMIZATION.md"
puts "  • Tests: test/product_listing_optimization_test.rb"
puts "  • Source: lib/raider/apps/product_listing_optimization.rb"
puts
