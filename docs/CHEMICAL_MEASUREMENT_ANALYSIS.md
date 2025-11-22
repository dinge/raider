# Chemical Measurement Device Analysis

A Raider app for analyzing images from chemical measurement devices, extracting measurement values, identifying devices, and providing comprehensive analysis reports.

## Overview

The `AnalyzeChemicalMeasurement` app uses vision-enabled LLMs to:

1. **OCR and extract measurements** from device displays
2. **Identify the measurement device** (brand, model, type)
3. **Lookup device information** (specifications, calibration requirements, best practices)
4. **Generate human-readable reports** with structured data and interpretations

## Features

- ✅ Supports any image format containing a measurement device display
- ✅ Extracts multiple measurement parameters with units
- ✅ Identifies device brand, model, and specifications
- ✅ Provides calibration and maintenance guidance
- ✅ Returns both structured JSON and human-readable text output
- ✅ Handles metadata (sample ID, operator, timestamps, etc.)
- ✅ Built-in persistence support with Rails integration
- ✅ VCR recording for reproducibility

## Usage

### Basic Usage

```ruby
require 'raider'

# Analyze a measurement device image
app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
  input: '/path/to/device_image.jpg',
  inputs: {}
)

# Get human-readable output
puts app.output

# Get structured data
puts app.outputs.to_json
```

### With Metadata

```ruby
app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
  input: '/path/to/device_image.jpg',
  inputs: {
    sample_id: 'SAMPLE-2025-001',
    operator: 'John Doe',
    location: 'Lab A',
    timestamp: '2025-01-15 14:30:00',
    notes: 'Weekly quality control check'
  }
)
```

## Output Structure

### Human-Readable Output

The `app.output` contains a comprehensive text summary with sections:

- **Executive Summary**: Key findings at a glance
- **Device Information**: Identified device details
- **Measurement Results**: All measured parameters with quality indicators
- **Device Context**: Specifications and capabilities
- **Quality Considerations**: Factors affecting accuracy
- **Recommendations**: Suggested actions (calibration, maintenance, etc.)
- **Additional Notes**: Metadata and other relevant information

### Structured JSON Output

The `app.outputs` contains:

```ruby
{
  device: {
    device_name: "Mettler Toledo SevenCompact S220",
    manufacturer: "Mettler Toledo",
    model: "S220",
    series: "SevenCompact",
    device_type: "pH meter",
    measurement_types: ["pH", "Temperature", "mV"],
    key_features: [...],
    typical_range: {...},
    typical_accuracy: {...},
    confidence_level: "high",
    identification_basis: "..."
  },

  measurements: [
    {
      parameter: "pH",
      value: 7.42,
      unit: "pH",
      quality: "good",
      timestamp: "2025-01-15 14:30:00"
    },
    {
      parameter: "Temperature",
      value: 25.3,
      unit: "°C",
      quality: "good",
      timestamp: "2025-01-15 14:30:00"
    }
  ],

  device_details: {
    technical_specifications: {
      measurement_range: {...},
      accuracy: {...},
      resolution: {...}
    },
    calibration_info: {
      frequency: "Daily before use",
      procedure: "...",
      required_standards: [...]
    },
    accuracy_factors: [...],
    maintenance: {...},
    troubleshooting: [...],
    best_practices: [...]
  },

  metadata: {
    # User-provided metadata echoed back
    sample_id: "SAMPLE-2025-001",
    operator: "John Doe",
    ...
  }
}
```

## Architecture

The app follows Raider's agent DSL pattern:

### App: `AnalyzeChemicalMeasurement`

Located in: `lib/raider/apps/analyze_chemical_measurement.rb`

Orchestrates the analysis workflow using multiple tasks:

1. OCR and extract measurements
2. Identify device
3. Lookup device information
4. Format human-readable response

### Tasks

#### 1. `OcrAndExtractMeasurements`

**File**: `lib/raider/tasks/ocr_and_extract_measurements.rb`

**Purpose**: Performs OCR on device display and extracts all measurement values

**Input**: Image path
**Output**: OCR text, measurements array, device text, status indicators

#### 2. `IdentifyDevice`

**File**: `lib/raider/tasks/identify_device.rb`

**Purpose**: Identifies the specific measurement device

**Input**: Image path + OCR data
**Output**: Device name, manufacturer, model, type, capabilities

#### 3. `LookupDeviceInfo`

**File**: `lib/raider/tasks/lookup_device_info.rb`

**Purpose**: Retrieves comprehensive device information

**Input**: Device identification
**Output**: Specifications, calibration info, maintenance, troubleshooting

#### 4. `FormatHumanResponse`

**File**: `lib/raider/tasks/format_human_response.rb`

**Purpose**: Generates human-readable summary

**Input**: All previous task outputs + metadata
**Output**: Formatted text report with sections

## Configuration

The app uses `gpt5_mini` by default for vision capabilities. To use a different model:

```ruby
# Modify in lib/raider/apps/analyze_chemical_measurement.rb
# Change llm: :gpt5_mini to another vision-capable model
```

Available options:
- `gpt5_mini` - Fast, cost-effective
- `gpt_4o_mini` - Good balance
- Vision-capable Ollama models for local deployment

## Rails Integration

When used in Rails with the `Raider::App` model:

```ruby
class MeasurementsController < ApplicationController
  def analyze
    app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
      input: params[:image].path,
      inputs: {
        sample_id: params[:sample_id],
        operator: current_user.name,
        location: params[:location]
      }
    )

    # Access persisted record
    measurement_record = app.persisted_app

    render json: {
      id: measurement_record.id,
      output: app.output,
      outputs: app.outputs,
      created_at: measurement_record.created_at
    }
  end
end
```

## Supported Device Types

The system is designed to work with various chemical measurement devices:

- **pH Meters**: Benchtop and portable
- **Spectrophotometers**: UV-Vis, colorimeters
- **Titrators**: Auto-titration systems
- **Ion Meters**: ISE, conductivity meters
- **Chromatographs**: HPLC, GC displays
- **Balances**: Analytical balances with displays
- **Thermometers**: Digital temperature measurement
- **Multi-parameter instruments**: Combined measurement devices

## Best Practices

### Image Quality

For best results, ensure images:

- Have clear, well-lit device displays
- Are in focus
- Show the entire display area
- Include device branding/model information when visible
- Are taken perpendicular to the display (minimize glare)

### Metadata

Always provide relevant metadata:

```ruby
inputs: {
  sample_id: 'Unique sample identifier',
  operator: 'Person performing measurement',
  location: 'Lab or measurement location',
  timestamp: 'Measurement date/time',
  project: 'Associated project or study',
  notes: 'Any relevant observations'
}
```

### Validation

The system provides confidence indicators. Always review:

- Device identification confidence level
- Measurement quality indicators
- Warnings or alerts in the output
- Calibration status if available

## Troubleshooting

### Poor OCR Results

- Check image quality (focus, lighting, resolution)
- Ensure device display is fully visible
- Try different image angles if glare is present

### Incorrect Device Identification

- Ensure device branding is visible in image
- Provide additional context in metadata
- Review confidence level and alternative models

### Missing Measurements

- Verify all measurement values are visible in image
- Check that display shows actual measurement (not menu/settings)
- Ensure image resolution is sufficient for small text

## Examples

See `examples/analyze_chemical_measurement_usage.rb` for complete usage examples.

## Development

### Testing

```bash
# Run tests
bundle exec rspec

# Run specific test
ruby test/analyze_chemical_measurement_test.rb
```

### Adding Support for New Device Types

1. Update `IdentifyDevice` system prompt with new manufacturers/models
2. Add device-specific specifications to `LookupDeviceInfo`
3. Test with sample images from the new device type

## License

Part of the Raider gem. See main LICENSE file.
