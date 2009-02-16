# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'rufus/scheduler'

include Algorithm

ActiveRecord::Base.allow_concurrency = true

scheduler ||= Rufus::Scheduler.start_new
puts "Scheduler in esecuzione.."

#test
scheduler.every("10s") do
  do_algorithm
  ActiveRecord::Base.verify_active_connections! 
end

#da sostituire con (la data di esecuzione andrà presa dal database o da un file)
#@job_id = @scheduler.at "Sun Oct 07 14:24:01 +0900 2009" :tags => [ "algorithm", "important" ] do
#  do_something
#  ActiveRecord::Base.verify_active_connections!  
#end

def scheduler.log_exception (e)
  ActiveRecord::Base.logger.warn("Si è verificato un problema: ", e)
end
