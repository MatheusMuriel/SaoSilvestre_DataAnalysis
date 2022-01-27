require 'httparty'
require 'zip'
require 'ogpr'
require 'nokogiri'
require 'cgi'
require 'json'

@url_base = "https://www.gazetaesportiva.com/sao-silvestre/resultados/"

html_page_base = HTTParty.get(@url_base)

doc = Nokogiri::HTML.parse(html_page_base.body)
menu_resultados = doc.at_css("ul#menu-resultados")

"""resultados_cada_ano = []
menu_resultados.css('li', 'menu-item').each do |resultado|
  resultados_cada_ano.push(resultado)
end"""

# Até 2006 os resultados eram disponibilizados em arquivo texto fwf
resultados_fwf = []
menu_resultados.css("li.menu-item-has-children").each do |resultado|
  resultados_fwf.push(resultado)
end

resultados_fwf.each do |result_ano|
  puts result_ano.css("a")
  puts "-----"
end
