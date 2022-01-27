require 'httparty'
require 'zip'
require 'ogpr'
require 'nokogiri'
require 'cgi'
require 'json'

regex_url = /^(http(s)?:\/\/www\.hackerrank\.com\/challenges\/){1}([a-zA-Z]|[0-9])+(\-([a-zA-Z]|[0-9])+)*\/(problem$)?/

puts "Bem vindo ao automatizador de desafios do HackerRank :D"

puts "Qual é o link do desafio que vc deseja?"

@url = gets

if !@url.match(regex_url)
    puts "Url invalida"
    exit
end

@url = @url.gsub(/\s|\n/, '').gsub(/\/problem$|\/problem\/$/, '')
@url_name = @url.split("/")[4]

@html_page = HTTParty.get(@url)

# Descobre e formata o nome do desafio
def get_name
    puts "... Buscando informações do desafio"
    # Busca e faz um parser das matatags da url
    #ogp = Ogpr.fetch(@url)
    ogp = Ogpr.parse(@html_page)
    titulo = ogp.title.gsub(/(\s\|\sHackerRank)$|\s/, '')
    puts "OK \n\n"
    return titulo
end

@nome_desafio = get_name()

# Download test cases
def get_testcase
    puts "... Baixando casos de teste"
    url_testecase = @url.gsub(/\/challenges\//, '/rest/contests/master/challenges/') + "/download_testcases"

    zip_file = HTTParty.get(url_testecase).body
    Zip::InputStream.open(StringIO.new(zip_file)) do |io|
        while entry = io.get_next_entry
            file_path = File.join(Dir.pwd, @nome_desafio, entry.name)

            FileUtils.mkdir_p(file_path) unless file_path.match(/\.txt$/)
            
            entry.extract(file_path) unless File.exist?(file_path)
        end
    end
    puts "OK \n\n"
end

get_testcase()

#Cria o arquivo de codigo
def get_code
    puts "... Criando arquivo de codigo"
    code_file = File.join(Dir.pwd, @nome_desafio, @nome_desafio + '.rb')
    FileUtils.touch code_file

    # Decodifica os templates do desafio
    doc = Nokogiri::HTML.parse(@html_page)
    initial_data_encoded = doc.at_css("script#initialData")
    initial_data_encoded = initial_data_encoded.to_str.gsub(/\n|\s/,'')

    initial_data = CGI::unescape(initial_data_encoded)

    json_init_data = JSON.parse(initial_data)
    
    challenge = json_init_data['community']['challenges']['challenge']

    detail = challenge['master/'+@url_name]['detail']

    template = detail['ruby_template']
    template_head  = detail['ruby_template_head'].gsub('#!/bin/ruby', '#!/bin/ruby' + "\n\n" + "# " + @url)
    template_tail = detail['ruby_template_tail']

    template_tail.slice! "fptr = File.open(ENV['OUTPUT_PATH'], 'w')\n\n"
    template_tail = template_tail.gsub(/(fptr\.write)\s.*/, '')
    template_tail = template_tail.gsub(/(fptr\.close\(\))/, 'puts result')
    template_tail = template_tail.gsub(/\n\n\n\n/, "\n")

    #Grava os templates no arquivo
    File.open(code_file, 'w') { |file|
        file.write(template_head)
        file.write(template)
        file.write(template_tail)
    }

    puts "OK\n\n"
end

get_code()

puts "Prontinho, bora codar! :D"
