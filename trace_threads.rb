#!/usr/bin/ruby -w

require 'rubygems'
require 'rmail'
require 'csv'
require 'pp'
require 'tree'

module Mailalytics
  def trace_threads
    messages = Hash.new
    roots = []
    mbox_files = Dir.glob("Mbox_Files/*.txt")
    mbox_files.each do |filename|
      File.open(filename, 'r') do |mbox|
        RMail::Mailbox.parse_mbox(mbox) do |raw|
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
      end
    end
    sizes = Array.new(100, 0)
    roots.each do |m|
      size = m.size
      sizes[size] += 1
    end
    sizes
  end

  def thread_length_csv
    rows = trace_threads
    puts 'length of thread, number of threads with said length'
    rows.each_index { |i| puts "#{i.to_s}, #{rows[i].to_s}" if rows[i] != 0 }
  end

end

include Mailalytics
thread_length_csv
