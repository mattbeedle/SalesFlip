module SimilarTo

  #
  # The most common German company name postfixes
  #
  POSTFIXES = %w[
    gmbh
    mbh
    ag
    kg
    kgaa
    eg
    e.g.
    ev
    e.v.
  ]

  #
  # A simple regex for matching company name postfixes, equivalent to:
  #   /(?!^)\b(gmbh|mbh|...)\b/i
  #
  POSTFIX_REGEX =
    /(?!^)\b(#{POSTFIXES.map { |_| Regexp.escape(_) }.join("|")})(\b|$)/i

  #
  # This method returns a collection of leads or accounts that are similar to
  # the object passed in.
  #
  # This is most useful for detecting potential duplicate leads:
  #
  #     Lead.create(company: "Bayern GmbH & Co. OHG")
  #
  #     lead = Lead.new(company: "Bayern")
  #     Lead.all.similar_to(lead).count # => 1
  #
  def similar_to(source)
    adapter = repository.adapter
    target_field = Account == self ? :name : :company
    company = Account === source ? source.name : source.company

    # We can't search for similar leads if we don't have a company name.
    return [] unless company.present?

    # If the source is saved, make sure not to include it in the results.
    scope = self === source && source.saved? ? all(:id.not => source.id) : all

    # First we see if there are any leads with exactly the same name, in which
    # case we can skip the more expensive searches.
    leads = scope.all(:conditions => ["lower(#{target_field}) = lower(?)", company])

    return leads if leads.any?

    # If the lead has a company postfix, we attempt to search for leads with
    # the same company name but no postfix.
    if index = company =~ POSTFIX_REGEX
      company = company[0, index].strip

      leads = scope.all(:conditions => ["lower(#{target_field}) = lower(?)", company])

      return leads if leads.any?
    end

    # Finally, we fall back to a broad search based on the common set of
    # German company postfixes.
    scope.all(:conditions => [
      POSTFIXES.map { "lower(#{target_field}) like lower(?)" }.join(" or "),
      *POSTFIXES.map { |postfix| "#{company} #{postfix}%" }
    ])
  end

end
