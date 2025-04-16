# frozen_string_literal: true

module Raider
  module Tasks
    class FetchBasicLetterInfo < Base
      def process(image)
        set_system_prompt(system_prompt)
        chat_message_with_images(prompt_en, [image])
      end

      def system_prompt
        <<~TEXT
          You are a specialized document analysis expert with the following capabilities:
          - Deep understanding of business documents and their structure
          - Expertise in German business correspondence
          - Precise extraction of dates, names, and document types
          - Accurate recognition of company letterheads and logos
          - Reliable handling of different document layouts

          Focus areas:
          1. Accurate text extraction from images
          2. Proper date format conversion, the current year is #{Time.now.year}
          3. Reliable sender/receiver identification
          4. Correct document type classification
        TEXT
      end

      def prompt_en
        <<~TEXT
          Make a deep research and document analysis and extract following data:
          1. The sender (from letterhead, company logo, or sender details, or sender address block)
          2. The recipient (from address block or recipient field)
          3. The primary document date (the current year is #{Time.now.year})
          4. The document type in German

          Important:
          - Use YYYY-MM-DD format for dates
          - For Category use the most fitting german type like (rechnung, mahnung, anschreiben, angebot, prüfung, steuerbescheinigung, lastschriftmandat, verschiedenes)
          - if no category fits exactly, find out what type the document is
          - Use "unknown" for unclear values, don't hallucinate
          - No additional text or explanations
          - Focus on accuracy and maintain the exact JSON structure

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          sender_name: 'Company or person who sent the document',
          receiver_name: 'Company or person receiving the document',
          main_date: 'Main document date in YYYY-MM-DD format',
          category: 'Document category in German language'
        }
      end

      # def prompt_en_old
      #   <<~TEXT
      #     Act as a professional experienced document analysis expert.
      #     You can read and understand German text.
      #     You have to analyze given business document, it is likely in German language - but can also be in English.
      #     Read the document and extract following information:

      #     1. The sender (from letterhead, company logo, or sender details, or sender address block)
      #     2. The recipient (from address block or recipient field)
      #     3. The primary document date (the current year is #{Time.now.year})
      #     4. The document type in German

      #     Important:
      #     - Use YYYY-MM-DD format for dates
      #     - For Category use the most fitting german type like (rechnung, mahnung, anschreiben, angebot, prüfung, verschiedenes)
      #     - if no category fits exactly, find out what type the document is
      #     - Use "unknown" for unclear values, don't hallucinate
      #     - No additional text or explanations
      #     - Focus on accuracy and maintain the exact JSON structure

      #     #{json_instruct}
      #   TEXT
      # end

      # def prompt_de
      #   <<~TEXT
      #     Du bist ein Experte für Dokumentenanalyse. Analysiere das angehängte Bild.
      #     Es handelt sich um ein gescanntes oder fotografiertes deutschsprachiges Geschäftsdokument.
      #     Extrahiere die folgenden Informationen:

      #     1. Absender – aus Briefkopf, Firmenlogo, Absenderadresse oder Kontaktdaten.
      #     2. Empfänger – aus Adressfeld oder Empfängerangabe.
      #     3. Hauptdatum des Dokuments – im Format JJJJ-MM-TT. Wenn kein Jahr angegeben ist, gehe von 2025 aus.
      #     4. Dokumenttyp auf Deutsch – zum Beispiel: rechnung, mahnung, anschreiben, angebot, prüfung, verschiedenes.

      #     Wichtig:
      #     - Verwende für das Datum das Format JJJJ-MM-TT (ISO).
      #     - Verwende bei der Kategorie nur den zutreffendsten deutschen Begriff.
      #     - Falls keine Kategorie exakt passt, nutze den passendsten deutschen Ausdruck.
      #     - Wenn Informationen fehlen oder unklar sind, schreibe "unknown".
      #     - Keine Schätzungen oder Fantasiedaten.
      #     - Keine zusätzlichen Erklärungen oder Kommentare.

      #     Gib ausschließlich ein JSON-Objekt im folgenden Format zurück:

      #     {
      #       "sender_name": "Firma oder Person, die das Dokument gesendet hat",
      #       "receiver_name": "Firma oder Person, die das Dokument erhalten hat",
      #       "main_date": "Datum des Dokuments im Format JJJJ-MM-TT",
      #       "category": "Dokumenttyp auf Deutsch"
      #     }
      #   TEXT
      # end
    end
  end
end
