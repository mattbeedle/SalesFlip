# encoding: UTF-8
require 'test_helper.rb'

class CompanyNormalizerTest < ActiveSupport::TestCase

  def assert_similar(reference, target)
    assert_equal reference.downcase, CompanyNormalizer.normalize(target)
  end

  should "remove company postfixes" do
    assert_similar "DATEV", "datev"
    assert_similar "Nanoscribe", "Nanoscribe GmbH"

    assert_similar "HOLY FASHION GROUP Strellson", "HOLY FASHION GROUP Strellson AG"

    assert_similar "Gesellschaft Technologieentwicklung", "Gesellschaft Technologieentwicklung mbH"

    assert_similar "LUTZ", "LUTZ GmbH & Co. KG"

    assert_similar "Cinemaxx Entertainment", "CinemaxX Entertainment GmbH & Co KG"
    assert_similar "Bayern", "Bayern GmbH & Co. OHG"
    assert_similar "pbp Preissinger", "pbp Preissinger GmbH Co. KG"
    assert_similar "Autohaus Degel", "Autohaus Degel GmbH Co.KG"

    assert_similar "ANDREAS STIHL", "ANDREAS STIHL AG & Co. KG"
    assert_similar "CEWE COLOR", "CEWE COLOR AG & Co. OHG"
    assert_similar "Wings of Germany Betreiber", "Wings of Germany Betreiber AG & Co.KG"
    assert_similar "SARSTEDT", "SARSTEDT AG & Co."

    assert_similar "Bundesverband WindEnergie", "Bundesverband WindEnergie e.V."
    assert_similar "Altenpflegeheim St. Katharina", "Altenpflegeheim St. Katharina e. V."

    assert_similar "Bruder Spielwaren", "Bruder Spielwaren GmbH + Co. KG"

    assert_similar "KATHREIN-Werke", "KATHREIN-Werke KG"
    assert_similar "WESSLING Holding", "WESSLING Holding GmbH & Co. KG"

    assert_similar "Nolte moebel-industrie Holding", "Nolte moebel-industrie Holding GmbH & Co. KGaA"
    assert_similar "engelhorn", "engelhorn KGaA"
    assert_similar "CLAAS", "CLAAS KGaA mbH"
    assert_similar "Dragerwerk", "Dragerwerk AG & Co. KGaA"

    assert_similar "DATEV", "DATEV eG"
    assert_similar "DATEV", "DATEV e.G."

    assert_similar "E.G.O. Control Systems", "E.G.O. Control Systems GmbH"
    assert_similar "Krankenpflege", "Krankenpflege eV"

  end

  should "transliterate foreign characters" do
    assert_similar "Sachs Montage- und Schweisstechnik", "Sachs Montage- und Schweißtechnik"
    assert_similar "Bruecke Rendsburg", "Brücke Rendsburg"
    assert_similar "HUECO electronic", "HÜCO electronic"
    assert_similar "Deutscher Aerzte-Verlag", "Deutscher Ärzte-Verlag"
    assert_similar "Regierungspraesidium Freiburg", "Regierungspräsidium Freiburg"
    assert_similar "Koepp Automatisierung", "Köpp Automatisierung"
    assert_similar "RHOEN-KLINIKUM", "RHÖN-KLINIKUM"
    assert_similar "Societe Generale S.A.", "Société Générale S.A."
  end

end
