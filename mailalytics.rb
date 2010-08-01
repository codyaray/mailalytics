#!/usr/bin/ruby -w

require 'rubygems'
require 'ostruct'
require 'rmail'
require 'tree'
require 'csv'

module Mailalytics
  
  MAX_BUCKET = 100 # Assume no more than 100 messages per month
  
  def member_stats_to_csv mbox
    stats = extract_member_stats mbox
    
    rows = []
    rows << ["Name", "Total Msg Count", "New Msg Count", "Msg Reply Count"]
    stats.each { |r| rows << [r[0], r[1].msg_total_count.to_s, r[1].msg_new_count.to_s, r[1].msg_reply_count.to_s] }

    data_to_csv rows
  end
  
  def message_frequency_to_csv mbox
    stats = extract_member_stats mbox
    
    rows = []
    (0..MAX_BUCKET).each { |i| rows << [i, 0, 0, 0] }
    stats.each do |r|
      rows[r[1].msg_total_count][1] += 1
      rows[r[1].msg_new_count][2] += 1
      rows[r[1].msg_reply_count][3] += 1
    end

    rows[0][1] = -1 # we don't have data on how many people never sent any messages 
    rows.unshift ["# Messages", "# People (Total Msgs)", "# People (New Msgs)", "# People (Replies Msgs)"]

    data_to_csv rows
  end

  def thread_length_to_csv mbox
    roots, unused = trace_threads mbox
    
    rows = []
    (1..MAX_BUCKET).each { |i| rows << [i, 0] }
    roots.each do |m|
      size = m.size
      rows[size-1][1] += 1
    end

    rows.unshift ["length of thread", "number of threads with said length"]
    
    data_to_csv rows
  end
  
  private

    def extract_member_stats mbox
      stats = {}

      RMail::Mailbox.parse_mbox(mbox) do |raw|
        message = RMail::Parser.read(raw)

        name = message.header["From"]
        (STDERR.puts message or next) if name == nil
        name[/\((.*)\)/] # Normalize based upon name, not email.
        name = $1        # From-header format: "me@example.com (First Last)"

        reply_count_diff = (message.header["In-Reply-To"]) ? 1 : 0
        new_count_diff = (reply_count_diff == 1) ? 0 : 1

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

      stats
    end

    def trace_threads mbox
      roots = []
      messages = {}
      
      RMail::Mailbox.parse_mbox(mbox) do |raw|
        message = RMail::Parser.read(raw)

        message_id = message.header["Message-ID"]
        messages[message_id] = Tree::TreeNode.new(message_id, message)

        reply_to = message.header["In-Reply-To"]

        unless reply_to
          roots << messages[message_id]
        else
          begin
            messages[reply_to] << messages[message_id] if messages.has_key? reply_to
          rescue
            next
          end
        end
      end

      return roots, messages
    end
    
    def data_to_csv rows
      buf = ''
      size = rows[0].length
      rows.each { |row| CSV.generate_row(row, size, buf) }

      buf
    end
end

include Mailalytics

mbox = STDIN.readlines.join("\r\n")
puts member_stats_to_csv(mbox)
puts message_frequency_to_csv(mbox)
puts thread_length_to_csv(mbox)
