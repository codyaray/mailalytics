#!/usr/bin/ruby -w

require 'rubygems'
require 'ostruct'
require 'rmail'
require 'csv'
require 'pp'

module Mailalytics
  def extract_stats
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
          new_count_diff = reply_count_diff == 1 ? 0 : 1

          if stats.has_key? name
            record = stats[name]
            record.msg_total_count += 1
            record.msg_new_count += new_count_diff
            record.msg_reply_count += reply_count_diff
          else
            record = OpenStruct.new
            record.msg_total_count = 1
            record.msg_new_count = new_count_diff
            record.msg_reply_count = reply_count_diff
            stats[name] = record
          end
        end
      end      
    end
    
    stats
  end
end