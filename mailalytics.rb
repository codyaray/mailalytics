#!/usr/bin/ruby -w

require 'rubygems'
require 'pathname'
require 'rmail'

count = 0
filename = "2010-May.txt.gz"
File.open(Pathname.new(filename), 'r') do |mbox|
  RMail::Mailbox.parse_mbox(mbox) do |raw|
    count += 1
    print "#{count} mails\n"
    begin
      message = RMail::Parser.read(raw)
      puts message.header
    rescue NoMethodError
      print "Couldn't parse date header, ignoring broken spam mail\n"
    end
  end
end