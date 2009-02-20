 module MigrationHelper
  def constraint_name(table, column)
    "fk_#{table}_#{column}"
  end

#Metodo che controlla il rispetto del vincolo di integrità in fase di inserimento.
#Se la chiave esterna assume un valore non valido verrà segnalo un errore
#Attreverso la variabile can_be_null è possibile indicare se la chiave esterna può
#essere nulla.
#from_table=individua il dome della tabella che contiene la chiave esterna
#from_column=individua il nome della colonna che contiene la chiave esterna
#to_table=individua la tabella associata

  def constraint_on_create(from_table, from_column, to_table,can_be_null)
    if(can_be_null==0)
      execute %(CREATE TRIGGER insert_#{constraint_name(from_table, from_column)}
              BEFORE INSERT ON #{from_table}
              FOR EACH ROW BEGIN
              SELECT CASE
               WHEN ((SELECT id FROM #{to_table} WHERE id = NEW.#{from_column}) IS NULL)
               THEN RAISE(ABORT, 'Creando, Violazione della chiave esterna #{from_column} della tabella #{from_table}')
               END;
              END;)

    else
        execute %(CREATE TRIGGER insert_#{constraint_name(from_table, from_column)}
              BEFORE INSERT ON #{from_table}
              FOR EACH ROW BEGIN
              SELECT CASE
               WHEN ((NEW.#{from_column} IS NOT NULL) AND (SELECT id FROM #{to_table} WHERE id = NEW.#{from_column}) IS NULL)
               THEN RAISE(ABORT, 'Creando, Violazione della chiave esterna #{from_column} della tabella #{from_table}')
               END;
              END;)
          end 
          end


#Metodo che controlla il rispetto del vincolo di integrità in fase di cancellazione
#from_table=>nome della tabella che contiene la riga da eliminare
#column=>nome della colonna che contiene la chiave esterna associata alla chiava primaria
#to_table=>nome della tabella che contiene la chiave esterna
#choose=>sceglie il tipo di cancellazione. se assume 0 si sceglie di non cancellare
#la riga se il suo id è associato. se assume 1 la cancellazione metterà le chiavi esterne
#associate a NULL
 def constraint_on_delete(from_table,column,to_table,choose)
 if(choose==0)
  execute %(CREATE TRIGGER delete_#{constraint_name(from_table, to_table)}
              BEFORE DELETE ON #{from_table}
              FOR EACH ROW BEGIN
              SELECT CASE
               WHEN ((SELECT #{column} FROM #{to_table} WHERE #{column} = OLD.id) IS NOT NULL)
               THEN RAISE(ABORT,'Eliminando, Violazione della chiave esterna #{column} della tabella #{from_table}')
               END;
              END;)

 else
   execute %(CREATE TRIGGER delete_#{constraint_name(from_table, to_table)}
            BEFORE DELETE ON #{from_table}
            FOR EACH ROW BEGIN
            UPDATE #{to_table} SET #{column}='null' WHERE #{column} = OLD.id;
            END;)

 end

end

#UPDATE
#Metodo che controlla il rispetto del vincolo di integrità in fase di aggiornamento
#Come funzionamento vedi constraint_on_create, sono simili
 def constraint_on_update(from_table, column, to_table,can_be_null)
    if(can_be_null==0)
      execute %(CREATE TRIGGER update_#{constraint_name(from_table,column)}
                BEFORE UPDATE ON #{from_table}
                FOR EACH ROW BEGIN
                SELECT CASE
                 WHEN ((SELECT id FROM #{to_table} WHERE id = new.#{column}) IS NULL)
                  THEN RAISE(ABORT, 'Aggiornando, Violazione della chiave esterna #{column} della tabella #{from_table}')
                END;
                END;)
      else
       execute %(CREATE TRIGGER update_#{constraint_name(from_table,column)}
                BEFORE UPDATE ON #{from_table}
                FOR EACH ROW BEGIN
                SELECT CASE
                 WHEN ((new.#{column} IS NOT NULL) AND
                    (SELECT id FROM #{to_table} WHERE id = new.#{column}) IS NULL)
                 THEN RAISE(ABORT, 'Aggiornando, Violazione della chiave esterna #{column} della tabella #{from_table}')
                END;
                END;)
             end
             end

end

