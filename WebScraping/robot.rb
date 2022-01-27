require 'httparty'
require 'nokogiri'
require 'json'

@url_base = "https://www.gazetaesportiva.com/sao-silvestre/resultados/"

html_page_base = HTTParty.get(@url_base)

doc = Nokogiri::HTML.parse(html_page_base.body)
menu_resultados = doc.at_css("ul#menu-resultados")

# Até 2006 os resultados eram disponibilizados em arquivo texto fwf
resultados_fwf = []
menu_resultados.css("li.menu-item-has-children").each do |resultado|
  resultados_fwf.push(resultado)
end

map_results = {}
resultados_fwf.each do |result_ano|
  map_results[result_ano.css("a")[0].content] = {
    result_ano.css("a")[1].content => result_ano.css("a")[1]["href"],
    result_ano.css("a")[2].content => result_ano.css("a")[2]["href"]
  }
end


File.open("results_fwf.json","w") do |f|
  f.write(JSON.pretty_generate(map_results))
end

result_dir = File.join(Dir.pwd, "resultados")
if not File.directory?(result_dir) then
  Dir.mkdir(result_dir)
end

map_results.each do |ano, modalidades|
  modalidades.each do |modalidade, link|
    result_ano_modalidade = File.join(Dir.pwd, "resultados", ano+"_"+modalidade+".txt")
    File.open(result_ano_modalidade,"w") do |f|
      f.write(HTTParty.get(link))
    end
  end
end
