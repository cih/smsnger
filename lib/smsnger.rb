require 'rubygems'
require 'yaml'
require 'pony'
# Copyright (c) 2008 Brendan G. Lim (brendangl@gmail.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SMSnger
  def self.setup(options = {})
    default_options = {
      :config => File.join(File.dirname(__FILE__),"carriers.yml"),
      :from => "noreply@domain.com",
      :mail_via => :sendmail
    }
    default_options.merge!(options)
    
    @@mail_via ||= default_options[:mail_via]
    
    raise SMSngerExceptions.new("You must specify a :from address setting in SMSnger.setup!") unless default_options.has_key?(:from)
    @@from_address = default_options[:from]
    
    if @@mail_via == :smtp
      raise SMSngerExceptions.new("You must specify the :smtp settings in SMSnger.setup!") unless default_options.has_key?(:smtp)
      smtp_config(default_options[:smtp]) 
    end
    
    load_carriers(default_options[:config])
    
    return default_options
  end

  def self.carrier_name(key)
    carriers[key]['name']
  end

  def self.carriers
    @@carriers.dup
  end

  def self.deliver_sms(number,carrier,message,options={})
    raise SMSngerException.new("Cannot deliver an empty message to #{format_number(number)}") if message.nil? or message.empty?

    options[:limit] ||= message.length
    options[:from]  ||= @@from_address
    message = message[0..options[:limit]-1]
    sms_email = determine_sms_email(format_number(number),carrier)
    
    case @@mail_via
    when :sendmail
      Pony.mail(:to => sms_email, :from => options[:from], :body => message)
    when :smtp
      Pony.mail(:to => sms_email, :from => options[:from], :body => message, :via => @@mail_via, :smtp => @@smtp_settings)
    else
      raise SMSngerException.new("Unknown mail method #{@@mail_via}.")
    end
    
  rescue SMSngerException => exception
    raise exception
  end

  def self.get_sms_address(number,carrier)
    number = format_number(number)
    determine_sms_email(number,carrier)
  end

  private
    def self.load_carriers(carrier_path)
      @@carriers     ||= YAML.load_file(carrier_path)
    end
  
    def self.smtp_config(smtp_config_hash)
      unless @@mail_via == :sendmail
        @@smtp_settings ||= smtp_config_hash
      end
    end

    def self.format_number(number)
      pre_formatted = number.gsub("-","").strip
      formatted =  (pre_formatted.length == 11 && pre_formatted[0,1] == "1") ? pre_formatted[1..pre_formatted.length] : pre_formatted
      return is_valid?(formatted) ? formatted : (raise SMSngerException.new("Phone number (#{number}) is not formatted correctly"))
    end

    def self.is_valid?(number)
      number.length >= 10 && number[/^.\d+$/]
    end  

    def self.determine_sms_email(phone_number, carrier)
      if @@carriers.has_key?(carrier.downcase)
        "#{phone_number}#{@@carriers[carrier.downcase]['value']}"
      else 
        raise SMSngerException.new("Specified carrier, #{carrier} is not supported.")
      end
    end 
end

SMSnger.setup

class SMSngerException < StandardError; end