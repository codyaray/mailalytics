#!/usr/bin/ruby -w

require 'rubygems'
require 'rmail'
require 'csv'
require 'pp'
require 'tree'

module Mailalytics
  def trace_threads mail_data
    messages = Hash.new
    roots = []
    RMail::Mailbox.parse_mbox(mail_data) do |raw|
      message = RMail::Parser.read(raw)
      
      message_id = message.header["Message-ID"]
      messages[message_id] = Tree::TreeNode.new(message_id, message)
      
          reply_to = message.header["In-Reply-To"]
      
      if not reply_to
        roots << messages[message_id]
      else
        begin
          messages[reply_to] << messages[message_id] if messages.has_key? reply_to
        rescue
          next
        end
      end
    end
    
    sizes = Array.new(100, 0)
    roots.each do |m|
      size = m.size
      sizes[size] += 1
    end
    sizes
  end

  def thread_length_csv mail_data
    rows = trace_threads mail_data
    puts 'length of thread, number of threads with said length'
    rows.each_index { |i| puts "#{i.to_s}, #{rows[i].to_s}" }
  end

end

include Mailalytics
mail_data = $stdin.readlines.join("\r\n")
thread_length_csv mail_data
