#!/usr/bin/ruby -w

require 'rubygems'
require 'pathname'
require 'rmail'
require 'pp'
require 'ostruct'

count = 0
stats = {}
mbox_files = Dir.glob("Mbox_Files/*.txt")
mbox_files.each do |filename|
  File.open(Pathname.new(filename), 'r') do |mbox|
    RMail::Mailbox.parse_mbox(mbox) do |raw|
      count += 1

      message = RMail::Parser.read(raw)

      name = message.header["From"]
      pp message and continue if name == nil
      name[/\((.*)\)/]
      name = $1

      if stats.has_key? name
        record = stats[name]
        record.msg_count += 1
        record.msg_is_reply += 1
      else
        record = OpenStruct.new
        record.msg_count = 1
        record.msg_is_reply = message.header.field?("In-Reply-To") ? 1 : 0
        stats[name] = record
      end
    end
  end
end

pp stats

print "#{count} mails\n"
