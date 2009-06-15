namespace :install do
  desc "Creazione di una nuova segreteria, un nuovo presidente del CCS ed un nuovo corso di laurea"
  task(:setup_db => :environment) do
    fail = true
    while (fail)
      confirm = "NO"
      didactic_office_mail = nil
      didactic_office_password = nil
      presidente_mail = nil
      presidente_password = nil
      presidente_name = nil
      presidente_surname = nil
      city = nil
      street = nil
      tel = nil
      gs_name = nil
      gs_academic_organization = nil
      gs_duration = nil
      while (!confirm.eql?("SI"))
        print "Inserisci l'indirizzo e-mail della nuova segreteria: "
        didactic_office_mail = STDIN.gets.chomp
        print "\n"
        print "Inserisci la password della nuova segreteria: "
        didactic_office_password = STDIN.gets.chomp
        print "\n"
        print "Inserisci l'indirizzo e-mail del nuovo presidente del CCS: "
        presidente_mail = STDIN.gets.chomp
        print "\n"
        print "Inserisci la password del nuovo presidente del CCS: "
        presidente_password = STDIN.gets.chomp
        print "\n"
        print "Inserisci il nome del nuovo presidente del CCS: "
        presidente_name = STDIN.gets.chomp
        print "\n"
        print "Inserisci il cognome del nuovo presidente del CCS: "
        presidente_surname = STDIN.gets.chomp
        print "Inserisci la città dell'indirizzo del nuovo presidente del CCS: "
        city = STDIN.gets.chomp
        print "\n"
        print "Inserisci la via dell'indirizzo del nuovo presidente del CCS: "
        street = STDIN.gets.chomp
        print "\n"
        print "Inserisci il numero di telefono dell'ufficio del nuovo presidente del CCS (es. 123-123456): "
        tel = STDIN.gets.chomp
        print "\n"
        print "Inserisci il nome del nuovo corso di laurea: "
        gs_name = STDIN.gets.chomp
        print "\n"
        ordinamenti = AcademicOrganization.find(:all)
        puts "Ordinamenti disponibili: "
        ordinamenti.each do |o|
          puts((ordinamenti.index(o) +1).to_s + "- " + o.name)
        end
        print "Inserisci il numero dell'ordinamento del nuovo corso di laurea: "
        id = STDIN.gets.chomp.to_i
        unless id == 0
          id = 1
        end
        gs_academic_organization = ordinamenti[id - 1]
        print "\n"
        print "Inserisci la durata in anni del nuovo corso di laurea: "
        gs_duration = STDIN.gets.chomp
        print "\n"
        puts "RIEPILOGO: "
        puts "Indirizzo e-mail segreteria didattica: " + didactic_office_mail
        puts "Password segreteria didattica " + didactic_office_password
        puts "Indirizzo e-mail presidente CCS: " + presidente_mail
        puts "Password presidente CCS: " + presidente_password
        puts "Nome presidente CCS: " + presidente_name
        puts "Cognome presidente CCS: " + presidente_surname
        puts "Città presidente CCS: " + city
        puts "Indirizzo presidente CCS: " + street
        puts "Numero di telefono presidente CCS: " + tel
        puts "Nome del corso di laurea: " + gs_name
        puts "Ordinamento corso di laurea: " + gs_academic_organization.name
        puts "Durata corso di laurea: " + gs_duration
        puts "Confermi? (SI o NO)"
        confirm = STDIN.gets.chomp
      end
      begin
        didactic_office = nil
        presidente_ccs = nil
        address = nil
        user_didactic_office = nil
        user_presidente_ccs = nil
        graduate_course = nil
        User.transaction do
          didactic_office = DidacticOffice.create()
          presidente_ccs = Teacher.new(:name => presidente_name, :surname => presidente_surname)
          address = Address.new(:street => street, :city => city, :telephone => tel)
          address.save!
          presidente_ccs.save!
          user_didactic_office = User.new(:mail => didactic_office_mail, :password => didactic_office_password,
                                          :random => 10, :address => nil, :specified => didactic_office)
          user_presidente_ccs = User.new(:mail => presidente_mail, :password => presidente_password,
                                         :random => 15, :address => address, :specified => presidente_ccs)
          graduate_course = GraduateCourse.new(:name => gs_name, :duration => gs_duration, :academic_organization => gs_academic_organization)
          if user_didactic_office.save! && user_presidente_ccs.save! && graduate_course.save!
            user_didactic_office.graduate_courses << graduate_course
            user_presidente_ccs.graduate_courses << graduate_course
            user_didactic_office.capabilities << Capability.find(:all)
            user_presidente_ccs.capabilities << Capability.find(:all)
            puts "------------------------------"
            puts "SETUP COMPLETATO CON SUCCESSO"
            puts "------------------------------"
            fail = false;
          end
        end
      rescue
        puts "------------------------------"
        puts "SETUP FALLITO"
        puts "------------------------------"
        puts "RILEVATI I SEGENTI ERRORI"
        if (presidente_ccs)
          puts presidente_ccs.errors.full_messages
        end
        if (address)
          puts address.errors.full_messages
        end
        if (user_didactic_office)
          puts user_didactic_office.errors.full_messages
        end
        if (user_presidente_ccs)
          puts user_presidente_ccs.errors.full_messages
        end
        if (graduate_course)
          puts graduate_course.errors.full_messages
        end
        puts "\n\n\n"
      end
    end
  end
end