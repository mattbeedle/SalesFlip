class CompanyNormalizer

  POSTFIXES = [
    # These postfixes will greedily chop company names to reduce the number
    # of variations needed to test. For example, "Company GmbH & Co OHG" will
    # be immediately truncated to "Company".
    /\bGmbH\b/i,       # GmbH
    /\bmbH\b/i,        # mbH
    /\bAG\b/i,         # AG
    /\bKG\b/i,         # KG
    /\bKGaA\b/i,       # KGaA

    # These postfixes only will only match at the end of company names, such
    # as "Company e.V.".
    /\be\.?\s?V\.?$/i, # eV, e.v., e. v.
    /\beG$/i,          # eG
    /\be\.G\.$/i       # e.G.
  ]

  class << self

    # Normalizes a company name for easier comparisons and duplicate
    # checking.
    #
    # It applies the following filters:
    #
    #   1. Transliteration: replaces UTF-8 characters with normal characters
    #   2. Downcasing
    #   3. Company Postfix Filtering
    #
    def normalize(name)
      name = I18n.transliterate(name).downcase

      POSTFIXES.each do |postfix|
        if index = name.rindex(postfix)
          name = name[0, index]
        end
      end

      name.strip
    end

  end
end
