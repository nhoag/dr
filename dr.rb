require 'wombat'
require 'json'

table = Wombat.crawl do
  base_url "http://www.tdcj.state.tx.us"
  path "/death_row/dr_executed_offenders.html"

  headline xpath: "//h1"

  people 'xpath=//table/tbody/tr', :iterator do
    execution "xpath=./td[1]"
    first_name "xpath=./td[5]"
    last_name "xpath=./td[4]"
    race "xpath=./td[9]"
    age "xpath=./td[7]"
    date "xpath=./td[8]"
    county "xpath=./td[10]"
    statement "xpath=./td[3]/a/@href"
  end
end

data = {}
table['people'].each do |x|
  last_words = Wombat.crawl do
    base_url "http://www.tdcj.state.tx.us"
    path "/death_row/#{x['statement']}"
    statement xpath: "//p[text()='Last Statement:']/following-sibling::p"
  end
  x['statement'] = last_words['statement']
  x['gender'] = 'male'
  unless x['execution'].nil?
    data[x['execution']] = x
    data[x['execution']].delete('execution')
  end
end

File.open('data/dr.json', 'w') do |f|
  f.puts data.to_json
end
