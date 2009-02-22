class AddConstraintOnDeleteSpecifiedForTeacherAndDidacticOffice < ActiveRecord::Migration
  def self.up
    execute %( CREATE TRIGGER on_delete_specified_constraint_teachers
            BEFORE DELETE ON teachers
              FOR EACH ROW BEGIN
              SELECT CASE
                WHEN ((SELECT id FROM users WHERE specified_id =OLD.id AND specified_type='Teacher') IS NOT NULL)
                  THEN RAISE(ABORT, 'Non puoi eliminare questo insegnante perche' e' associato ad uno user')
                END;
               END;
              )

   execute %( CREATE TRIGGER on_delete_specified_constraint_didactic_offices
            BEFORE DELETE ON didactic_offices
              FOR EACH ROW BEGIN
              SELECT CASE
                WHEN ((SELECT id FROM users WHERE specified_id = OLD.id AND specified_type='DidacticOffice') IS NOT NULL)
                  THEN RAISE(ABORT, 'Non puoi eliminare questa segreteria didattica perche' e' associato ad uno user')
                END;
               END;
              )
  end

  def self.down
    execute %(DROP TRIGGER on_delete_specified_constraint_didactic_offices)
    execute %(DROP TRIGGER IF EXISTS on_delete_specified_constraint_teachers)

  end
end
