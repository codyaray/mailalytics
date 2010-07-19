#!/usr/bin/ruby -w

require 'rubygems'
require 'ostruct'
require 'rmail'
require 'csv'

stats = {}
mbox_files = Dir.glob("Mbox_Files/*.txt")
mbox_files.each do |filename|
  File.open(filename, 'r') do |mbox|
    RMail::Mailbox.parse_mbox(mbox) do |raw|
      message = RMail::Parser.read(raw)

      name = message.header["From"]
      pp message and continue if name == nil
      name[/\((.*)\)/]
      name = $1
      
      reply_count_diff = message.header.field?("In-Reply-To") ? 1 : 0

      if stats.has_key? name
        record = stats[name]
        record.msg_count += 1
        record.msg_reply_count += reply_count_diff
      else
        record = OpenStruct.new
        record.msg_count = 1
        record.msg_reply_count = reply_count_diff
        stats[name] = record
      end
    end
  end
end

src = []
src << ["Name", "Total Msg Count", "Msg Reply Count"]
stats.each { |r| src << [r[0], r[1].msg_count.to_s, r[1].msg_reply_count.to_s] }

buf = ''
src.each { |row| CSV.generate_row(row, 3, buf) }

puts buf