require 'erb'
require 'resolv'
require 'pry'

class App
  def call(env)
    req = Rack::Request.new(env)
    path = req.path_info

    case path
    when '/'
      url = req.params["url"]

      if url
        render("home", url: url, name_servers: name_servers_for(url))
      else
        render("home")
      end
    else
      handle_missing_path
    end
  end

  private

  def render(template, status_code: 200, **locals)
    @locals = locals
    @content = render_template(template)
    body = render_template("layout")
    headers = {"Content-Type" => "text/html; charset=utf-8"}

    [status_code, headers, [body]]
  end

  def render_template(template)
    template = File.read("./app/views/#{template}.html.erb")
    erb = ::ERB.new(template)
    erb.result(binding)
  end

  def handle_missing_path
    body = File.read("./public/404.html")
    headers = {"Content-Type" => "text/html; charset=utf-8"}

    [404, headers, [body]]
  end

  def name_servers_for(url)
    host = URI(url).host
    res = Resolv::DNS.new
    res.getresources(host, Resolv::DNS::Resource::IN::NS)
  end
end