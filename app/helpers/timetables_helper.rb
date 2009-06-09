module TimetablesHelper
  MONTHS_NAMES = ["Gennaio","Febbraio","Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre","Novembre", "Dicembre"]
  def self.current_year
    now = Time.now
    if now.month < 8
      first = (now.year - 1).to_s
      second = now.year
      second = (second.to_s)[-2,2]
      return first + "/" + second
    else
      first = now.year
      second = now.year + 1
      second = (second.to_s)[-2,2]
      return first + "/" + second
    end
  end
end
