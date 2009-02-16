# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'rufus/scheduler'

ActiveRecord::Base.allow_concurrency = true

scheduler ||= Rufus::Scheduler.start_new

#test
scheduler.every("10s") do
  puts "puttanate ogni 10s  "
end

#da sostituire con (la data di esecuzione andrà presa dal database o da un file)
#@job_id = @scheduler.at "Sun Oct 07 14:24:01 +0900 2009" do
#  do_something()
#  ActiveRecord::Base.verify_active_connections!  
#end
