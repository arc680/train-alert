# coding: UTF-8

require 'sinatra'
require 'sinatra/reloader'
require 'open-uri'
require 'nokogiri'
require 'json'

def get_list_traininfo(url)
  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end
  #puts "charset #{charset}"

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  # 運行情報をまとめている部分の取得
  traininfo_list = []
  statusTrubuleLine = doc.css('#mdStatusTroubleLine')
  status = statusTrubuleLine.css('.elmTblLstLine.trouble').text.gsub(/(\r\n|\r|\n)/, '')
  if status == '事故・遅延情報はありません'
    puts status
  else
    # url のリストを作成する
    unless (statusTable = statusTrubuleLine.css('.elmTblLstLine.trouble table')).empty?
      statusTable.css('table a').each do |traininfo|
      # start for dev
      #f2 = File.open('./table.html')
      #doc2 = Nokogiri::HTML(f2, nil, charset)
      #doc2.css('body table a').each do |traininfo|
      # end for dev
        traininfo_list.push(traininfo.attribute('href').text)
      end
    end

    #puts statusTrubuleLine
    #puts status
  end

  traininfo_list
end

# URL リストにある路線それぞれの運行情報を取得する
def get_detail_traininfo(url_list=[])
  detail_traininfo = {
    'info' => [],
    'num' => 0
  }
  # start of dev
  test_list = [
    'http://transit.yahoo.co.jp/traininfo/detail/21/0/',
    'http://transit.yahoo.co.jp/traininfo/detail/38/0/',
    'http://transit.yahoo.co.jp/traininfo/detail/40/0/',
    'http://transit.yahoo.co.jp/traininfo/detail/86/0/',
    'http://transit.yahoo.co.jp/traininfo/detail/133/0/',
    'http://transit.yahoo.co.jp/traininfo/detail/139/0/'
  ]
  # end of dev
  charset = 'utf-8'
  p test_list
  # start of dev
  #test_list.each do |url|
  # end of dev
  url_list.each do |url|
    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
    doc2 = Nokogiri::HTML.parse(html, nil, charset)
    base = doc2.css('.mainWrp')
    name = base.css('.labelLarge h1.title').text
    date = base.css('.labelLarge span.subText').text
    status = base.css('#mdServiceStatus dt').text.gsub(/(\r\n|\r|\n)/, '').gsub(/(\[.*\])/, '')
    icon = base.css('#mdServiceStatus dt span').attribute('class').value
    if icon == 'icnNormalLarge'
      message = base.css('#mdServiceStatus .normal').text.gsub(/(\r\n|\r|\n)/, '')
    else
      message = base.css('#mdServiceStatus .trouble').text.gsub(/(\r\n|\r|\n)/, '')
    end
    data = {
      'name' => name,
      'date' => date,
      'status' => status,
      'icon' => icon,
      'message' => message
    }
    #p data
    detail_traininfo['info'].push(data)
  end
  
  detail_traininfo['num'] = detail_traininfo['info'].length
  detail_traininfo.to_json
end

get "/" do
  # スクレイピング先のURL
  url = 'http://transit.yahoo.co.jp/traininfo/area/4/'
  list_traininfo = get_list_traininfo(url)
  get_detail_traininfo(list_traininfo)
end