# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'rufus/scheduler'

module Algorithm
    @scheduler ||= Rufus::Scheduler.start_new

  def self.test_output
    return rand
  end

  def self.schedule_output_generation
    @scheduler.in('10s') do
      puts "output ind 10s  #{test_output}"
    end
  end
end

