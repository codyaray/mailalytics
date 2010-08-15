#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '../lib/mailalytics')
include Mailalytics

mbox = STDIN.readlines.join("\r\n")
puts member_stats_to_csv(mbox)
