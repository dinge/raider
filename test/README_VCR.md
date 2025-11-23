# VCR Test Setup for Chemical Measurement Analysis

This directory contains VCR cassettes and test data for testing the `AnalyzeChemicalMeasurement` app without requiring an actual OpenAI API key.

## What is VCR?

VCR records HTTP interactions (like API calls to OpenAI) and replays them during tests. This allows tests to run:
- Without needing API credentials
- Faster (no network latency)
- Consistently (same responses every time)
- Offline (no internet connection required)

## Test Data

### Test Image
- **Location**: `test/data/chemical_device_ph_meter.ppm`
- **Type**: Simple PPM format image (text-based, easily version controlled)
- **Represents**: A pH meter display showing measurements

### VCR Cassettes

Located in `test/vcr_cassettes/analyze_chemical_measurement/0/test-001/`:

1. **ocr_and_extract_measurements--0--gpt5_mini--.yml**
   - Mocked OCR response extracting pH 7.42 and Temperature 25.3°C
   - Device text: "Mettler Toledo"
   - Sample ID: "LAB-2025-001"

2. **identify_device--0--gpt5_mini--.yml**
   - Device identification: Mettler Toledo SevenCompact S220 pH Meter
   - High confidence identification
   - Complete specifications and features

3. **lookup_device_info--0--gpt5_mini--.yml**
   - Technical specifications
   - Calibration procedures
   - Maintenance guidelines
   - Troubleshooting information

4. **format_human_response--0--gpt5_mini--.yml**
   - Complete formatted report
   - Executive summary, measurements, recommendations
   - ~1000 token comprehensive response

## Running Tests

### Simple VCR Verification
```bash
ruby -I lib:test test/vcr_simple_test.rb
```

This test verifies:
- VCR cassettes exist
- Test image exists
- VCR configuration is correct

### Unit Tests (No API Required)
```bash
ruby -I lib:test test/analyze_chemical_measurement_test.rb
```

All unit tests run without network access, testing:
- Class structure
- Method signatures
- Response schemas

### Integration Test (Work in Progress)
```bash
ruby -I lib:test test/analyze_chemical_measurement_integration_test.rb
```

**Note**: Full integration test requires debugging agent context initialization.
The VCR infrastructure is ready, but the Raider framework needs updates to support
fully mocked agent workflows.

## How It Works

### Cassette Path Structure
```
analyze_chemical_measurement/  # App ident
└── 0/                         # Version key
    └── test-001/              # Source ident
        └── task--number--llm--.yml  # Task cassette
```

### VCR Configuration

Located in `test/test_helper.rb`:

```ruby
VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
  config.allow_http_connections_when_no_cassette = false
end
```

## Cassette Format

Each cassette is a YAML file containing:
- **Request**: HTTP method, URI, headers, body
- **Response**: Status code, headers, body (JSON with LLM response)
- **Metadata**: Recording timestamp, VCR version

Example response structure:
```yaml
http_interactions:
- request:
    method: post
    uri: https://api.openai.com/v1/chat/completions
    body: {...}
  response:
    status:
      code: 200
    body: '{"choices":[{"message":{"content":"```json\n{...}\n```"}}]}'
  recorded_at: Thu, 25 Jan 2025 14:30:00 GMT
```

## Creating New Cassettes

To record new cassettes with actual API calls:

1. Set your OpenAI API key:
   ```bash
   export OPENAI_API_KEY=your-key-here
   ```

2. Delete existing cassettes (or move them):
   ```bash
   rm test/vcr_cassettes/analyze_chemical_measurement/0/test-001/*.yml
   ```

3. Run the test with VCR in `:new_episodes` mode:
   ```bash
   ruby -I lib:test test/analyze_chemical_measurement_integration_test.rb
   ```

4. VCR will record the actual API responses

## Benefits

✅ **No API Key Required** - Tests run with pre-recorded responses
✅ **Fast** - No network latency
✅ **Deterministic** - Same results every time
✅ **CI/CD Ready** - No secrets needed in CI pipeline
✅ **Offline Development** - Work without internet
✅ **Cost Effective** - No API calls during testing
✅ **Version Controlled** - Cassettes are committed with code

## Maintenance

### When to Update Cassettes

- When LLM prompts change significantly
- When response structure changes
- When upgrading to newer LLM models
- When improving response quality

### Cassette Review

Always review cassettes before committing:
- Ensure no sensitive data is recorded
- Verify responses are representative
- Check that JSON structures match expectations

## Troubleshooting

### "VCR cassette not found" Error
- Verify cassette path matches the app/task configuration
- Check cassette filename format: `task--number--llm--.yml`
- Ensure VCR is configured in test_helper.rb

### "Unmocked HTTP Request" Error
- VCR is trying to make a real API call
- Either create the cassette or allow the specific request
- Check `allow_http_connections_when_no_cassette` setting

### Tests Pass Locally But Fail in CI
- Ensure cassettes are committed to version control
- Verify test/vcr_cassettes directory is not in .gitignore
- Check file paths are relative, not absolute

## Future Improvements

- [ ] Fix agent context initialization for full integration tests
- [ ] Add more test scenarios (different devices, error cases)
- [ ] Create cassettes for failure scenarios
- [ ] Add visual regression tests for formatted output
- [ ] Document cassette updating workflow
