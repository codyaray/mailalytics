require 'mailalytics'

module Mailalytics
  MAX_BUCKET = 100 # Assume no more than 100 messages per month

  def calc_message_frequency
    stats = extract_stats
    
    src = []
    (0..MAX_BUCKET).each { |i| src << [i, 0, 0, 0] }
    stats.each do |r|
      src[r[1].msg_total_count][1] += 1
      src[r[1].msg_new_count][2] += 1
      src[r[1].msg_reply_count][3] += 1
    end

    src[0][1] = -1 # we don't have data on how many people never sent any messages 
    src.unshift ["# Messages", "# People (Total Msgs)", "# People (New Msgs)", "# People (Replies Msgs)"]

    buf = ''
    src.each { |row| CSV.generate_row(row, 4, buf) }

    buf
  end
end

include Mailalytics
puts calc_message_frequency