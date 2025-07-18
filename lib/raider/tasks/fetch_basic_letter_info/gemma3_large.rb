# frozen_string_literal: true

module Raider
  module Tasks
    class FetchBasicLetterInfo
      class Gemma3Large < FetchBasicLetterInfo
        VALID_CATEGORIES = %w[rechnung kontoauszug kassenbeleg betriebsprufung prüfung änderung
                              lastschrift auftrag kontoabschluss
                              steuerbescheinigung bescheinigung änderung mieterhöhung
                              mahnung nebenkostenabrechnung abrechnung einzugsermachtigung verschiedenes]

        def process(image, valid_values)
          set_system_prompt('')
          chat_message_with_images(prompt(valid_values), [image])
        end

        def system_prompt_in_prompt(valid_values)
          <<~SYSTEM
            You are a specialized document analysis expert with the following capabilities:
            - Deep understanding of business letters and their structure
            - Expertise in German business correspondence
            - Precise extraction of dates, names and document types
            - Accurate recognition of company letterheads and logos
            - Reliable handling of different document layouts

            #{objective(valid_values)}

            Always respond in valid JSON format.
          SYSTEM
        end

        def objective(valid_values)
          <<~TEXT
            OBJECTIVE:
            1. Proper sender_date extraction
              - sender_date will be mostly in the upper right corner
              - sender_date is not in the main text body
              - sender_date will be often the first date
              - sender_date can be in %d.%m.%Y Format
              - or sender_date can be in %d. %B %Y Format
              - or sender_date can be in a other proper date format
              - the sender_date must before #{Time.now.strftime('%d.%m.%Y')}.
              - the year of the sender_date will be likely #{Time.now.year} or #{Time.now.year - 1}.
            2. Reliable sender_name identification
              - sender_name is often in upper right corner,
              - sender_name is not in this list #{valid_values.join(', ')}
            3. Reliable receiver_name identification
              - receiver_name is one of this very possible receiver_names #{valid_values.join(', ')}.
              - ignore patterns like GmbH while comparison with very possible receiver_names
              - if needed use advanced algorythms like Jaro-Winkler Distance and N-gram
            4. Correct document type classification
              - these are very possible categories #{VALID_CATEGORIES.join(', ')}.
          TEXT
        end

        def prompt(valid_values)
          <<~TEXT
            #{system_prompt_in_prompt(valid_values)}

            Extract important information from german business letter.

            Extract Fields:
            sender_name
            receiver_name
            sender_date
            category

            Make a deep research and no errors.

            #{json_instruct}
          TEXT
        end

        def example_response_struct
          {
            sender_name: 'Company or person who sent the document',
            receiver_name: 'Company or person receiving the document',
            sender_date: 'Main document date in YYYY-MM-DD format',
            category: 'Document category in German language'
          }
        end
      end
    end
  end
end
