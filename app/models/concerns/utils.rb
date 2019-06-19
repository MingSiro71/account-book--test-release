module Utils
  def transrate(word, from, to)
    reference = dictionary
    reference.find{|item| item[:"#{from}"] == word}[:"#{to}"] || raise
  end

  def en_(word)
    transrate(word, "ja", "en")
  end

  def ja_(word)
    transrate(word, "en", "ja")
  end
end