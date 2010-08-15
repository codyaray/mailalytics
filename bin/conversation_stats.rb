#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '../lib/mailalytics')
include Mailalytics

mbox = STDIN.readlines.join("\r\n")
puts thread_length_to_csv(mbox)
