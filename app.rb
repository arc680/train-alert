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
  #p test_list
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
  #'{"info":[{"name":"中d央線(快速)[東京～高尾]","date":"6月14日 12時48分更新","status":"運転状況","icon":"icnAlertLarge","message":"09:24頃、中央総武線(各停)内で発生した人身事故の影響で、現在も一部列車に遅れや運休が出ています。（6月14日 12時00分掲載）"},{"name":"中央総武線(各停)","date":"6月14日 12時46分更新","status":"運転状況","icon":"icnAlertLarge","message":"09:24頃、飯田橋駅で発生した人身事故の影響で、現在も一部列車に遅れが出ています。なお、東京メトロ東西線との直通運転を中止しています。（6月14日 12時15分掲載）"},{"name":"京成押上線","date":"6月14日 12時48分更新","status":"運転状況","icon":"icnAlertLarge","message":"08:14頃、都営浅草線内で安全確認を行った影響で、現在も列車に遅れや運休が出ています。（6月14日 09時15分掲載）"},{"name":"京急本線","date":"6月14日 12時48分更新","status":"運転状況","icon":"icnAlertLarge","message":"08:14頃、都営浅草線内で安全確認を行った影響で、現在も一部列車に遅れや運休が出ています。（6月14日 10時20分掲載）"},{"name":"京急空港線","date":"6月14日 12時48分更新","status":"運転状況","icon":"icnAlertLarge","message":"08:14頃、都営浅草線内で安全確認を行った影響で、現在も一部列車に遅れや運休が出ています。（6月14日 10時20分掲載）"},{"name":"都営浅草線","date":"6月14日 12時48分更新","status":"運転状況","icon":"icnAlertLarge","message":"08:14頃、本所吾妻橋駅で安全確認を行った影響で、現在も列車に遅れや運休が出ています。（6月14日 09時20分掲載）"},{"name":"東京メトロ東西線","date":"6月14日 12時48分更新","status":"運転状況","icon":"icnAlertLarge","message":"09:24頃、JR中央総武線(各停)内で発生した人身事故の影響で、現在もJR中央総武線(各停)との直通運転を中止しています。（6月14日 11時00分掲載）"},{"name":"北総線","date":"6月14日 12時48分更新","status":"列車遅延","icon":"icnAlertLarge","message":"08:14頃、都営浅草線内で安全確認を行った影響で、現在も列車に遅れが出ています。（6月14日 10時00分掲載）"}],"num":8}'
end