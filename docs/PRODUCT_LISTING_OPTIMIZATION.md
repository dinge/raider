# Product Listing Optimization

A comprehensive Raider app that transforms raw product images and basic information into fully optimized e-commerce listings with SEO content, A/B test variants, and quality scoring.

## Overview

The Product Listing Optimization app uses AI-powered analysis to create professional, conversion-optimized product listings for e-commerce platforms. It combines computer vision, competitive intelligence, SEO optimization, and A/B testing to maximize listing performance.

### Business Value

- **Revenue Impact**: Optimized listings can increase conversion rates by 25-40%
- **Time Savings**: Automates 2-3 hours of manual copywriting and research per product
- **Consistency**: Ensures all listings follow proven best practices
- **Testing**: Generates A/B variants to continuously improve performance
- **Competitive**: Analyzes market positioning and differentiation opportunities

### Key Features

1. **Vision AI Product Analysis** - Analyzes product images to identify features, quality, and selling points
2. **Competitive Intelligence** - Researches category best practices, keywords, and pricing strategies
3. **SEO Optimization** - Creates optimized titles, descriptions, bullet points, and keyword sets
4. **A/B Variant Generation** - Produces 3 distinct test variants targeting different buyer psychologies
5. **Quality Scoring** - Evaluates listings across 6 dimensions with actionable improvement recommendations

## Architecture

The app orchestrates 5 specialized tasks in a sequential workflow:

```
Product Images → Analyze Images → Research Competitors → Optimize SEO →
                                                          ↓
                    Quality Score ← A/B Variants ←  Generate Variants
```

### Task Breakdown

#### 1. AnalyzeProductImages
- **Input**: Product image(s) (single image or array)
- **LLM**: GPT-5 Mini (vision model)
- **Output**: Product identification, features, visual quality, target audience, USPs
- **Purpose**: Extract product intelligence from images to inform content creation

#### 2. ResearchCompetitors
- **Input**: Product category or keywords
- **LLM**: GPT-5 Mini
- **Output**: Top keywords, title patterns, pricing insights, feature emphasis, SEO tips
- **Purpose**: Understand competitive landscape and best practices

#### 3. OptimizeSeo
- **Input**: Product context from image analysis
- **LLM**: GPT-5 Mini
- **Output**: Optimized title (60-80 chars), description (150-200 words), 5 bullet points, 20-25 keywords
- **Purpose**: Create SEO-optimized, conversion-focused content

#### 4. GenerateAbVariants
- **Input**: Optimized SEO content
- **LLM**: GPT-5 Mini
- **Output**: 3 test variants (Feature-focused, Benefit-focused, Social Proof-focused)
- **Purpose**: Create testable hypotheses for different customer segments

#### 5. CalculateQualityScore
- **Input**: All previous outputs
- **LLM**: GPT-5 Mini
- **Output**: Overall score (1-100), category scores, strengths, improvements, quick wins
- **Purpose**: Provide objective quality assessment and prioritized action items

## Usage

### Basic Usage

```ruby
require 'raider'

# Optimize a product listing with images
result = Raider::Apps::ProductListingOptimization.optimize(
  input: 'path/to/product_image.jpg',
  inputs: {
    category: 'wireless headphones',
    brand_voice: 'professional and aspirational',
    target_audience: 'busy professionals and frequent travelers'
  }
)

# Access the optimized listing
listing = result.outputs[:optimized_listing]
puts listing[:title]
puts listing[:description]
listing[:bullet_points].each { |bp| puts "• #{bp}" }

# Review quality score
score = result.outputs[:quality_score]
puts "Overall Score: #{score[:overall_score]}/100"
puts "Grade: #{score[:grade]}"

# View A/B test variants
variants = result.outputs[:ab_variants]
variants[:variants].each do |variant|
  puts "\n#{variant[:name]}"
  puts "Hypothesis: #{variant[:hypothesis]}"
  puts "Title: #{variant[:title]}"
end
```

### With Multiple Images

```ruby
# Analyze product with multiple angles
result = Raider::Apps::ProductListingOptimization.optimize(
  input: [
    'path/to/front_view.jpg',
    'path/to/side_view.jpg',
    'path/to/detail_shot.jpg'
  ],
  inputs: {
    category: 'kitchen appliances',
    price_point: '$299',
    brand_voice: 'modern and innovative'
  }
)
```

### With App Persistence

```ruby
# Enable persistence to save results to database
result = Raider::Apps::ProductListingOptimization.optimize(
  input: product_image_path,
  inputs: { category: 'electronics' },
  with_app_persistence: true
)

# Access persisted app record
app_record = Raider::App.find_by(ident: result.app_ident)
puts app_record.outputs  # All outputs stored as JSON
```

### Accessing Specific Outputs

```ruby
result = Raider::Apps::ProductListingOptimization.optimize(
  input: image_path,
  inputs: { category: 'home goods' }
)

# Image analysis results
image_analysis = result.outputs[:image_analysis]
product_type = image_analysis[:product_identification][:product_type]
key_features = image_analysis[:key_features]

# Competitive insights
research = result.outputs[:competitor_research]
top_keywords = research[:top_keywords]
price_range = research[:price_insights][:price_ranges]

# SEO content
seo = result.outputs[:seo_content]
title = seo[:title]
description = seo[:description]
keywords = seo[:keywords]

# A/B variants
variants = result.outputs[:ab_variants]
feature_focused = variants[:variants].find { |v| v[:variant_id] == 'A' }
benefit_focused = variants[:variants].find { |v| v[:variant_id] == 'B' }
social_proof = variants[:variants].find { |v| v[:variant_id] == 'C' }

# Quality assessment
quality = result.outputs[:quality_score]
improvements = quality[:improvements]
quick_wins = quality[:quick_wins]
```

## Output Structure

### Optimized Listing

```ruby
{
  title: "Sony WH-1000XM5 Noise Cancelling Wireless Headphones - Premium Sound...",
  description: "Transform your daily commute, work sessions, and travel...",
  bullet_points: [
    "🎧 UNMATCHED NOISE CANCELLATION: Industry-leading ANC technology...",
    "⚡ ALL-DAY POWER: 30-hour battery life with quick charge...",
    # ... 3 more bullets
  ],
  keywords: [
    "noise cancelling headphones",
    "wireless bluetooth headphones",
    # ... 20+ more keywords
  ]
}
```

### Quality Score

```ruby
{
  overall_score: 87,
  grade: "A",
  category_scores: {
    title_quality: 92,
    description_quality: 88,
    bullet_points: 85,
    seo_optimization: 90,
    visual_content: 80,
    competitive_positioning: 87
  },
  strengths: [
    "Excellent title optimization - front-loads primary keyword...",
    # ... 4 more strengths
  ],
  improvements: [
    {
      area: "Visual Content",
      issue: "Only 3 product images - competitors average 6-8 images",
      recommendation: "Add lifestyle images showing product in use...",
      impact: "high",
      effort: "medium",
      expected_lift: "15-25% conversion increase"
    },
    # ... 4 more improvements
  ],
  quick_wins: [
    "Add \"2-Year Warranty\" badge to title (+3 score points)",
    # ... 4 more quick wins
  ],
  conversion_predictions: {
    current_listing: {
      expected_cvr: "3.2-3.8%",
      vs_category: "Above average (category avg: 2.1%)"
    },
    with_improvements: {
      expected_cvr: "4.1-4.7%",
      potential_lift: "25-30%"
    }
  }
}
```

### A/B Variants

```ruby
{
  variants: [
    {
      variant_id: "A",
      name: "Feature-Focused (Technical Buyers)",
      title: "Sony WH-1000XM5: Advanced ANC Processor, 40mm Drivers...",
      bullet_points: ["🔧 ADVANCED TECHNOLOGY: HD Noise Cancelling...", ...],
      hypothesis: "Technical specifications and detailed features will appeal...",
      target_segment: "Tech enthusiasts, audiophiles, engineers...",
      learning_objective: "Determine if technical depth increases conversion...",
      expected_impact: "Higher conversion for informed buyers..."
    },
    # ... variants B and C
  ],
  test_recommendations: {
    sample_size_needed: "Minimum 100 conversions per variant for 95% confidence",
    test_duration: "2-4 weeks or until statistical significance",
    primary_metric: "Conversion rate (add to cart)"
  }
}
```

## Testing

### Unit Tests

The app includes comprehensive unit tests covering:
- App class existence and methods
- Task class definitions and inheritance
- Required method implementations
- Response structure validation
- Summary generation

Run tests:
```bash
ruby -Ilib:test test/product_listing_optimization_test.rb
```

### Integration Testing

For integration tests with real API calls:

```ruby
# Disable VCR to make real API calls
result = Raider::Apps::ProductListingOptimization.new(
  with_vcr: false,
  input: image_path,
  inputs: { category: 'electronics' }
).process!
```

## Configuration Options

### App Initialization Parameters

```ruby
Raider::Apps::ProductListingOptimization.new(
  input: image_path_or_array,
  inputs: {
    category: 'product category',           # Required for competitive research
    brand_voice: 'professional/casual/etc', # Optional: tone of content
    target_audience: 'audience description',# Optional: who is this for
    price_point: '$299',                    # Optional: for competitive positioning
  },
  with_app_persistence: false,              # Save to database
  with_auto_context: false,                 # Auto-populate context
  with_vcr: true,                          # Record/replay API calls
  llm: :gpt5_mini,                         # LLM to use
  on_task_create: :show_task_start         # Lifecycle hook
)
```

### Customizing LLM per Task

```ruby
# Use different LLMs for different tasks
app = Raider::Apps::ProductListingOptimization.new(
  input: image_path,
  inputs: { category: 'electronics' }
)

app.agents.optimize_listing(input: app.input) do |ag|
  # Use vision model for image analysis
  image_analysis = ag.tasks.analyze_product_images(
    llm: :gpt5_mini,
    input: app.input,
    inputs: app.inputs
  )

  # Use faster model for text tasks
  competitor_research = ag.tasks.research_competitors(
    llm: :gpt4o_mini,
    input: app.inputs[:category],
    inputs: { image_analysis: }
  )

  # Continue with workflow...
end
```

## Best Practices

### Image Quality
- Provide high-resolution images (1200x1200px minimum)
- Include multiple angles (front, side, detail shots)
- Use professional lighting and neutral backgrounds
- Show product in use for lifestyle context

### Category Specification
- Be specific: "wireless noise-cancelling headphones" > "headphones"
- Include key attributes: "premium wireless headphones for professionals"
- Match marketplace categories exactly if targeting specific platforms

### Brand Voice
- **Professional**: "Delivers exceptional performance with industry-leading technology"
- **Casual**: "Get crazy good sound without the crazy high price"
- **Luxury**: "Exquisite craftsmanship meets unparalleled acoustic excellence"
- **Technical**: "40mm neodymium drivers with 4-40kHz frequency response"

### Iterative Optimization
1. Run initial optimization
2. Review quality score and improvements
3. Implement high-impact recommendations
4. Re-run optimization to measure improvement
5. Launch A/B tests with top variants
6. Iterate based on conversion data

## Performance Considerations

### LLM Token Usage
Typical token usage per optimization:
- AnalyzeProductImages: ~2,000 tokens (vision model)
- ResearchCompetitors: ~1,500 tokens
- OptimizeSeo: ~2,500 tokens
- GenerateAbVariants: ~2,000 tokens
- CalculateQualityScore: ~3,000 tokens
- **Total**: ~11,000 tokens per product

### Execution Time
- With API calls: 15-30 seconds
- With VCR (cached): <1 second

### Cost Optimization
- Use VCR for development/testing to avoid API costs
- Batch process multiple products in parallel
- Cache competitive research results for products in same category
- Use `with_app_persistence` to avoid re-processing

## Integration Examples

### E-commerce Platform Integration

```ruby
class Product < ApplicationRecord
  def optimize_listing!
    result = Raider::Apps::ProductListingOptimization.optimize(
      input: self.primary_image_path,
      inputs: {
        category: self.category_name,
        brand_voice: self.brand.voice,
        target_audience: self.category.target_audience
      },
      with_app_persistence: true
    )

    # Update product with optimized content
    self.update!(
      title: result.outputs[:seo_content][:title],
      description: result.outputs[:seo_content][:description],
      bullet_points: result.outputs[:seo_content][:bullet_points],
      seo_keywords: result.outputs[:seo_content][:keywords],
      quality_score: result.outputs[:quality_score][:overall_score]
    )

    # Store A/B variants for testing
    result.outputs[:ab_variants][:variants].each do |variant|
      self.listing_variants.create!(
        variant_id: variant[:variant_id],
        title: variant[:title],
        bullet_points: variant[:bullet_points],
        hypothesis: variant[:hypothesis]
      )
    end
  end
end
```

### Bulk Processing

```ruby
# Optimize all products in a category
Product.where(category: 'electronics', quality_score: nil).find_each do |product|
  begin
    product.optimize_listing!
    puts "✓ Optimized: #{product.name}"
  rescue => e
    puts "✗ Failed: #{product.name} - #{e.message}"
  end
end
```

### A/B Testing Integration

```ruby
# Implement A/B test rotation
class ProductController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # Rotate through A/B variants
    variant_id = %w[control A B C].sample

    if variant_id == 'control'
      @title = @product.title
      @bullets = @product.bullet_points
    else
      variant = @product.listing_variants.find_by(variant_id: variant_id)
      @title = variant.title
      @bullets = variant.bullet_points
    end

    # Track which variant was shown
    track_variant_impression(variant_id)
  end
end
```

## Troubleshooting

### Common Issues

**Issue**: "No category provided in inputs"
- **Solution**: Always include `category` in inputs hash for competitive research

**Issue**: Image analysis returns generic results
- **Solution**: Provide higher resolution images or multiple angles

**Issue**: Quality score lower than expected
- **Solution**: Review `improvements` array for specific recommendations

**Issue**: A/B variants too similar
- **Solution**: Provide more context about target audience and differentiators

### Debug Mode

Enable debug logging to see detailed execution:

```ruby
Raider.logger.level = Logger::DEBUG

result = Raider::Apps::ProductListingOptimization.optimize(
  input: image_path,
  inputs: { category: 'electronics' },
  debug: true  # Enable detailed logging
)
```

## Roadmap

Future enhancements planned:
- [ ] Multi-language support for international markets
- [ ] Platform-specific optimization (Amazon, Shopify, eBay)
- [ ] Automated image quality enhancement suggestions
- [ ] Price optimization recommendations
- [ ] Competitor product comparison
- [ ] Automatic category detection from images
- [ ] Video analysis for product demonstrations

## License

Part of the Raider framework - see main repository for license information.
