#!/usr/bin/ruby -w

require 'rubygems'
require 'pathname'
require 'rmail'

Struct.new('Mail', :message, :parent)

def parse_messages(filename)
  messages = []

  File.open(Pathname.new(filename), 'r') do |mbox|
    RMail::Mailbox.parse_mbox(mbox) do |raw|
      begin
        messages.push Struct::Mail.new(RMail::Parser.read(raw), nil)
      rescue NoMethodError
        print "Couldn't parse date header, ignoring broken spam mail\n"
      end
    end
  end

  messages
end

def link_messages(list)
  list.each do |l|
    
  end
end

m = parse_messages "march-email.txt"
m.each {|x| p x.message.header.select('In-Reply-To') }
