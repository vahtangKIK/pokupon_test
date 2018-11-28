#encoding: utf-8

class Mailer

  require 'erb'
  require 'mail'

  def self.setup(smtp_options, mail_to, mail_from)
    @@mutex = Mutex.new
    @@options = {}
    smtp_options.each {|k,v| @@options[k.to_sym] = v }
    @@mail_to = mail_to
    @@mail_from = mail_from
    Mail.defaults do
      delivery_method :smtp, @@options
    end
  end

  def self.send_failed(hostname, status)
    template_file = './mail/mail_failed.erb'
    message = render_template(template_file, hostname: hostname, status: status)
    subject = 'Ошибка на хосте'
    send(message, subject)
  end

  def self.send_unreachable(hostname)
    template_file = './mail/mail_unreachable.erb'
    message = render_template(template_file, hostname: hostname)
    subject = 'Хост не отвечает'
    send(message, subject)
  end

private

  def self.send(message, subject)
    begin
      @@mutex.synchronize {
        Mail.deliver do
               to @@mail_to
             from @@mail_from
          subject subject
             body message
        end
      }
    rescue
      $logger.error "message delivery failed #{subject}"
    end
  end

  def self.render_template(template_file, **binds)
    begin
      template = ERB.new File.read(template_file)
      template.result(binding)
    rescue
      $log.fatal "bad template file #{template_file}"
      raise
    end 
  end
end