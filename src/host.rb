#encoding: utf-8

class Host
  
  require 'uri'
  require 'net/http'
  require 'rufus-scheduler'
  
  def initialize(url, interval)
    @uri = URI(url)
    @interval = "#{interval}s"
    @last_reachable = true # server did not respond
    @last_available = true # server responded not 200
    @mutex = Mutex.new
  end

  def run
    scheduler = Rufus::Scheduler.new
    scheduler.every @interval do |job| 
      @mutex.synchronize {
        check
      }   
     end
    self
  end

private

  def check
    begin
      response = nil
      unreachable = false
      Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https') do |http|
        req = Net::HTTP::Head.new(@uri) # use HEAD to check status
        response = http.request(req) 
      end
    rescue
      unreachable = true
    end
    if unreachable then
      $log.info("Host #{@uri.host} is unreachable")
      Mailer.send_unreachable(@uri.host) if @last_reachable
      @last_reachable = false
    elsif response.code == '200'
      @last_available = true
      @last_reachable = true
    else
      $log.info("Host #{@uri.host} is failed")
      Mailer.send_failed(@uri.host, response.code) if @last_available
      @last_available = false
      @last_reachable = true
    end
  end
end