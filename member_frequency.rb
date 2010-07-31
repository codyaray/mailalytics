require 'mailalytics'

module Mailalytics
  def calc_member_frequency
    stats = extract_stats
    
    src = []
    src << ["Name", "Total Msg Count", "New Msg Count", "Msg Reply Count"]
    stats.each { |r| src << [r[0], r[1].msg_total_count.to_s, r[1].msg_new_count.to_s, r[1].msg_reply_count.to_s] }

    buf = ''
    src.each { |row| CSV.generate_row(row, 4, buf) }

    puts buf
  end
end

include Mailalytics
puts calc_member_frequency