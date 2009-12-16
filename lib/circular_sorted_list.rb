#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: circular sorted list
* Description: simple circular sorted list
* Author: Joel Uchoa
* Date: 2009-11-26
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

class CircularSortedList

  class Node
    attr_reader :info
    attr_accessor :previous_node, :next_node

    def initialize(info, next_node=nil)
      @info = info
      if next_node.nil?
        @previous_node = @next_node = self
      else 
        @next_node, @previous_node = next_node, next_node.previous_node
        @next_node.previous_node = @previous_node.next_node = self
      end
    end

  end

  def initialize
    @root = nil
  end

  def empty?
    @root.nil?
  end

  def insert(info)
    if @root.nil?
      @root = Node.new(info)			
    elsif info < @root.info 
      @root = Node.new(info, @root)
    elsif info > @root.info
      node = @root.next_node
      while node != @root
        return node if info == node.info
        break if info < node.info
        node = node.next_node
      end
      Node.new(info, node)
    else
      @root
    end
  end

  def find(info)
    return @root if @root.info == info
    node = @root.next_node
    until node == @root
      return node if node.info == info
      node = node.next_node
    end
    nil
  end

  def remove(info)
    node = find(info)
    return false if node.nil?
    @root = node.next_node if @root == node
    node.previous_node.next_node = node.next_node
    node.next_node.previous_node = node.previous_node
    true
  end

  def to_s
    ret = ''
    unless @root.nil?
      ret = @root.info.to_s
      node = @root.next_node
      while node != @root
        ret += ', ' + node.info.to_s
        node = node.next_node
      end
    end
    '('+ret+')'
  end

end
