#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: task_scheduler.rb
#VERSIONE: 0.2.0
#AUTORE: Barbiero Mattia
#DATA CREAZIONE: 14/02/2009
#REGISTRO DELLE MODIFICHE:
#17/02/09 Aggiunta cron style e log exception
#16/02/09 Prima stesura
require 'rubygems'
require 'rufus/scheduler'

include Algorithm

#inizializzazione dell'algoritmo
@scheduler ||= Rufus::Scheduler.start_new
puts "Scheduler in esecuzione.."



def exec_cron(cron_string)
  @scheduler.schedule cron_string, :tags => [ "algorithm", "important" ] do
    do_algorithm
    ActiveRecord::Base.verify_active_connections!
  end
end

def execute_in(max_time)
  @scheduler.schedule_in max_time, :tags => [ "algorithm", "important" ] do
    do_algorithm
    ActiveRecord::Base.verify_active_connections!
 end
end


#utilizziamo la notazione stile cron
#* * * * *
#- - - - -
#| | | | |
#| | | | ----- giorno della settimana (0 - 7) (domenica = 0 oppure 7)
#| | | ------- mese (1 - 12)
#| | --------- giorno del mese (1 - 31)
#| ----------- ora (0 - 23)
#------------- minuti (0 - 59)



def @scheduler.log_exception (e)
  ActiveRecord::Base.logger.warn("Si è verificato un problema: ", e)
end

#esegue l'algoritmo in base alla stringa cron
exec_cron("53 17 * * *")

@scheduler.join
