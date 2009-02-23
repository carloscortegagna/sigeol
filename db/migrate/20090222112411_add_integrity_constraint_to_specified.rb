class AddIntegrityConstraintToSpecified < ActiveRecord::Migration
  def self.up
    execute %( CREATE TRIGGER on_create_specified_constraint
            BEFORE INSERT ON users
              FOR EACH ROW BEGIN
              SELECT CASE
                WHEN (NEW.specified_type IS NOT NULL AND NEW.specified_type != 'Teacher' AND NEW.specified_type != 'DidacticOffice')
                  THEN RAISE(ABORT, 'Lo user non ha un tipo specificato valido')
                WHEN (NEW.specified_type == 'Teacher' AND (SELECT id FROM teachers WHERE id = NEW.specified_id) IS NULL)
                  THEN RAISE(ABORT, 'Non esiste in teachers una riga con quel id')
                WHEN (NEW.specified_type == 'DidacticOffice' AND (SELECT id FROM didactic_offices WHERE id = NEW.specified_id) IS NULL)
                  THEN RAISE(ABORT, 'Non esiste in didactic_offices una riga con quel id')
                 END;
                END;
              )
   execute %( CREATE TRIGGER on_update_specified_constraint
            BEFORE UPDATE OF specified_id,specified_type ON users
              FOR EACH ROW BEGIN
              SELECT CASE
                WHEN ((NEW.specified_type IS NULL) OR (NEW.specified_type != 'Teacher' AND NEW.specified_type != 'DidacticOffice'))
                  THEN RAISE(ABORT, 'Lo user non ha un tipo specificato valido')
                WHEN (NEW.specified_type == 'Teacher' AND (SELECT id FROM teachers WHERE id = NEW.specified_id) IS NULL)
                  THEN RAISE(ABORT, 'Non esiste in teachers una riga con quel id')
                WHEN (NEW.specified_type == 'DidacticOffice' AND (SELECT id FROM didactic_offices WHERE id = NEW.specified_id) IS NULL)
                  THEN RAISE(ABORT, 'Non esiste in didactic_offices una riga con quel id')
                 END;
                END;
              )

  end

  def self.down
    execute %(DROP TRIGGER IF EXISTS specified_type_constraint)
    execute %(DROP TRIGGER IF EXISTS on_update_specified_constraint)
  end
end
