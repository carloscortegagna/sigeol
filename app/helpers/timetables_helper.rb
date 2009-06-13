  require 'rubygems'
  require 'mime/types'
  require 'net/http'
  require 'cgi'

module TimetablesHelper
  MONTHS_NAMES = ["Gennaio","Febbraio","Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre","Novembre", "Dicembre"]
  def self.current_year
    now = Time.now
    if now.month < 8
      first = (now.year - 1).to_s
      second = now.year
      second = (second.to_s)[-2,2]
      return first + "/" + second
    else
      first = now.year
      second = now.year + 1
      second = (second.to_s)[-2,2]
      return first + "/" + second
    end
  end
  class Param
    attr_accessor :k, :v
    def initialize( k, v )
      @k = k
      @v = v
    end

    def to_multipart
      #return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
      # Don't escape mine...
      return "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
    end
  end

  class FileParam
    attr_accessor :k, :filename, :content
    def initialize( k, filename, content )
      @k = k
      @filename = filename
      @content = content
    end

    def to_multipart
      #return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: #{MIME::Types.type_for(@filename)}\r\n\r\n" + content + "\r\n "
      # Don't escape mine
      return "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: #{MIME::Types.type_for(@filename)}\r\n\r\n" + content + "\r\n"
    end
  end
  class MultipartPost
    BOUNDARY = 'tarsiers-rule0000'
    HEADER = {"Content-type" => "multipart/form-data; boundary=" + BOUNDARY + " "}

    def prepare_query (params)
      fp = []
      params.each {|k,v|
        if v.respond_to?(:read)
          fp.push(FileParam.new(k, v.path, v.read))
        else
          fp.push(Param.new(k,v))
        end
      }
      query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, HEADER
    end
  end

  def self.post_form(url, query, headers)
    Net::HTTP.start(url.host, url.port) {|con|
      con.read_timeout = 0
      begin
        return con.post(url.path, query, headers)
      rescue => e
        puts "POSTING Failed #{e}... #{Time.now}"
      end
    }
  end

end
