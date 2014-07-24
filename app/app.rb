require 'sinatra/base'
require 'sqlite3'

class App < Sinatra::Application
  set :public_folder, './public'

  DB_PATH = File.expand_path('../../db/zipcode.db', __FILE__)

  before do
    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true # ハッシュ形式で列を返してくれる
  end

  after do
    @db.close
  end

  # 一覧
  get '/' do
    sql = "SELECT zipcode, address FROM zipcode_list"

    # zipcodeパラメータがあれば条件を付加
    if params[:zipcode]
      # 前方一致検索
      sql << " WHERE zipcode LIKE '#{SQLite3::Database.quote(params[:zipcode])}%'"
    end

    # 結果を100件に制限
    sql << ' ORDER BY id DESC LIMIT 100'
    @rows = @db.execute(sql)

    erb :index, layout: :layout
  end

  # 個別ページ
  get '/zipcode/:code' do
    sql = "SELECT zipcode, address FROM zipcode_list" +
      " WHERE zipcode = '#{params[:code]}'"

    @result = @db.execute(sql).first

    if @result
      erb :show, layout: :layout
    else
      'Not Found'
    end
  end

  # 新規追加
  post '/zipcode' do
    sql = "INSERT INTO zipcode_list(zipcode, address)" +
      " VALUES(:zipcode, :address)"

    @db.execute(sql, {
      zipcode: params[:zipcode],
      address: params[:address]
      })

    redirect to('/')
  end

  # 削除
  post '/zipcode/:code/delete' do
    sql = "DELETE FROM zipcode_list" +
      " WHERE zipcode = '#{params[:code]}'"

    @db.execute(sql)

    redirect to('/')
  end
end
