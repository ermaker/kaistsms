# encoding: utf-8
require 'rubygems'
require 'iconv'
require 'mechanize'
require 'nokogiri'
require 'logger'

OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = :SSLv3

class KaistSMS
  def initialize
    @agent = Mechanize.new
  end

  def main_page
    p = @agent.get('http://mail.kaist.ac.kr')
    p.frame('main').click
  end

  LOGIN_REGEXP = Regexp.new(Iconv.conv('cp949', 'UTF-8', '환영합니다'))
  def login userid, userpasswd
    p = main_page.form('login') do |f|
      f.USERS_ID = userid
      f.USERS_PASSWD = userpasswd
      f.action = 'https://mail.kaist.ac.kr/nara/servlet/user.UserServ'
      f.cmd = 'login'
    end.submit
    return p.body.force_encoding('cp949') =~ LOGIN_REGEXP
  end

  def sms_page
    @agent.get(main_page.search('//a[node()="SMS"]/@href'))
  end

  def quota
    return sms_page.form('f').quota.to_i
  end

  def sms from, to, msg
    p2 = sms_page.form('f') do |f|

      # from
      f.sendHp = from

      # to
      option_node = Nokogiri::HTML::DocumentFragment.parse("<option selected>#{to}</option>").child
      option = Mechanize::Form::Option.new(option_node, f.field('receiveHp'))
      f.field('receiveHp').options.push option

      # msg
      f.toMessage = msg
      f.receiveCount1 = 1

      # reserved?
      f.radiobutton('type').value = '0'

    end.submit
    result = p2.search('//span[@class="t_menu_vioB"]/node()').map(&:to_s).map(&:to_i)
    return {:total => result[0], :sent => result[1], :quota => result[2], :shortage => result[3], :error => result[4]}
  end

  class << self
    def quota userid, userpasswd
      kaist_sms = self.new
      return false unless kaist_sms.login userid, userpasswd
      kaist_sms.quota
    end

    def sms userid, userpasswd, from, to, msg
      kaist_sms = self.new
      return result = {:result => false} unless kaist_sms.login userid, userpasswd
      result = kaist_sms.sms(from, to, msg)
      result[:result] = result[:shortage] == 0 && result[:error] == 0 && result[:total] == result[:sent] ? true : false
      return result
    ensure
      log = Logger.new('log/kaistsms.log', 20, 1024*1024)
      log.debug { "userid: #{userid}" }
      log.debug { "size of msg: #{msg.size}" }
      result.each do |key,value|
        log.debug { "#{key}: #{value}" }
      end
      log.close
    end
  end
end
