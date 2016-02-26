$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

class ImageSizeApp < Sinatra::Base
  helpers Sinatra::JSON

  configure :development do
    Bundler.require :development
    register Sinatra::Reloader
  end

  get "/" do
    '/size?uri=http://example.com/a.jpg'
  end

  get "/size" do
    uri = params[:uri]
    unless uri
      halt 400, 'uri required'
    end

    unless uri.match(/^https?:\/\//i)
      halt 400, 'uri required'
    end

    content_type 'application/json'

    cache = Dalli::Client.new

    content = cache.get(uri)
    return content if content

    width, height = *FastImage.size(uri)
    content = json({ width: width, height: height})

    cache.set(uri, content, 3600*24)

    content
  end

end
