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

  url_list.each_with_index do |url, index|
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
      'index' => index,
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
  erb :index
end

get "/api" do
  redirect "/"
end

get "/api/" do
  redirect "/"
end


get "/api/traininfo" do
  # スクレイピング先のURL
  url = 'http://transit.yahoo.co.jp/traininfo/area/4/'
  list_traininfo = get_list_traininfo(url)
  get_detail_traininfo(list_traininfo)
  # for debug
  #'{"info":[{"index":0,"name":"埼京川越線[大崎～川越]","date":"8月24日 14時44分更新","status":"運転見合わせ","icon":"icnAlertLarge","message":"日進～西大宮駅間で安全確認を行っている影響で、大宮～川越駅間の運転を見合わせています。（8月24日 14時10分掲載）"},{"index":1,"name":"常磐線[水戸～いわき]","date":"8月24日 14時46分更新","status":"運転状況","icon":"icnAlertLarge","message":"東海～大甕駅間で発生した線路陥没の影響で、現在も列車に遅れや運休が出ています。（8月24日 14時00分掲載）"},{"index":2,"name":"総武線(快速)[東京～千葉]","date":"8月24日 14時44分更新","status":"列車遅延","icon":"icnAlertLarge","message":"総武本線内での大雨の影響で、一部列車に遅れが出ています。（8月24日 14時30分掲載）"},{"index":3,"name":"総武本線[千葉～銚子]","date":"8月24日 14時44分更新","status":"運転見合わせ","icon":"icnAlertLarge","message":"大雨の影響で、現在も佐倉～八街駅間の運転を見合わせています。なお、振替輸送を行っています。（8月24日 13時15分掲載）"},{"index":4,"name":"成田線[我孫子～成田]","date":"8月24日 14時46分更新","status":"運転見合わせ","icon":"icnAlertLarge","message":"大雨の影響で、安食～成田駅間の運転を見合わせています。また、運転区間の列車に遅れが出ています。（8月24日 13時45分掲載）"},{"index":5,"name":"成田線[佐倉～成田空港・銚子]","date":"8月24日 14時44分更新","status":"運転見合わせ","icon":"icnAlertLarge","message":"大雨の影響で、成田～滑河駅間の運転を見合わせています。また、運転区間の列車に遅れが出ています。（8月24日 13時45分掲載）"},{"index":6,"name":"西武多摩湖線","date":"8月24日 14時44分更新","status":"運転見合わせ","icon":"icnAlertLarge","message":"8月22日、武蔵大和～西武遊園地駅間で発生した土砂流入の影響で、本日も萩山～西武遊園地駅間の運転を見合わせています。（8月24日 05時00分掲載）"},{"index":7,"name":"京成本線","date":"8月24日 14時44分更新","status":"運転再開","icon":"icnAlertLarge","message":"大雨の影響で、京成成田～成田空港駅間の運転を見合わせていましたが、14:40現在、運転を再開しています。なお、列車に遅れや運休が出ています。（8月24日 14時40分掲載）"},{"index":8,"name":"京成東成田線","date":"8月24日 14時46分更新","status":"運転見合わせ","icon":"icnAlertLarge","message":"大雨の影響で、運転を見合わせています。（8月24日 14時20分掲載）"},{"index":9,"name":"芝山鉄道線","date":"8月24日 14時46分更新","status":"交通障害情報","icon":"icnAlertLarge","message":"24日14:20現在、芝山鉄道線は、大雨の影響で、運転を見合わせています。（8月24日 14時20分掲載）"},{"index":10,"name":"成田スカイアクセス","date":"8月24日 14時46分更新","status":"運転再開","icon":"icnAlertLarge","message":"大雨の影響で、空港第2ビル～成田空港駅間の運転を見合わせていましたが、14:40現在、運転を再開しています。なお、列車に遅れや運休が出ています。（8月24日 14時40分掲載）"}],"num":11}'
end