#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '../lib/mailalytics')
include Mailalytics

mbox = STDIN.readlines.join("\r\n")
puts message_frequency_to_csv(mbox)