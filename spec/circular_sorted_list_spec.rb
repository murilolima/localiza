#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac lib/circular_sorted_list.rb tests
* Description: this file contains the lib/circular_sorted_list.rb's tests 
* Author: Joel Uchoa
* Date: 2009-11-21
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'rubygems'
require 'spec'
require 'lib/circular_sorted_list'

describe CircularSortedList do
  
  it "should to add elements and to sort them" do
    list = CircularSortedList.new
    array = []
    1000.times { i = rand(100); list.insert(i); array << i; }
    list.to_s.should == '('+array.sort.uniq.join(', ')+')'
  end

end
