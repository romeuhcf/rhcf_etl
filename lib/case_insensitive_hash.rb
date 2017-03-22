require "active_support/hash_with_indifferent_access"

class CaseInsensitiveHash < HashWithIndifferentAccess
  # This method shouldn't need an override, but my tests say otherwise.
  def [](key)
    super convert_key(key)
  end

  protected

  def convert_key(key)
    if key.respond_to?(:downcase)
      key.to_s.downcase.parameterize.underscore
    else
      key
    end
  end
end
