package net.sf.cpsolver.itc.ctt.model;

import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;
import java.util.Vector;

import net.sf.cpsolver.ifs.model.Constraint;
import net.sf.cpsolver.ifs.model.ConstraintListener;
import net.sf.cpsolver.ifs.model.Value;

/**
 * Representation of a teacher. Two lectures that are associated with the same 
 * teacher cannot be placed at the same day and time.
 * 
 * @version
 * ITC2007 1.0<br>
 * Copyright (C) 2007 Tomas Muller<br>
 * <a href="mailto:muller@unitime.org">muller@unitime.org</a><br>
 * Lazenska 391, 76314 Zlin, Czech Republic<br>
 * <br>
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * <br><br>
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * <br><br>
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
public class CttTeacher {
    private CttModel iModel;
    private String iId;
    private TeacherConstraint iConstraint;
    private Vector iPreferences;
    
    /** 
     * Constructor
     * @param model problem model
     * @param id unique identifier
     */
    public CttTeacher(CttModel model, String id) {
        iModel = model;
        iId = id;
        iConstraint = new TeacherConstraint();
        iModel.addConstraint(iConstraint);
        /*add*/
        iPreferences = new Vector();
    }
    
    /** Return problem model */
    public CttModel getModel() {
        return iModel;
    }
    
    /** Return unique identifier */
    public String getId() {
        return iId;
    }
    
    /** Compare two teachers for equality */
    public boolean equals(Object o) {
        if (o==null || !(o instanceof CttTeacher)) return false;
        return getId().equals(((CttTeacher)o).getId());
    }
    
    /** Hash code */
    public int hashCode() {
        return getId().hashCode();
    }
    
    /** String representation */
    public String toString() {
        return getId();
    }
    
    /** Return appropriate teacher constraint */
    public TeacherConstraint getConstraint() {
        return iConstraint;
    }
    
    /**
     * Teacher constraint. This hard constraint ensures that two
     * lectures that are taught by the same teacher are not placed
     * at the same day and time.
     */
    public class TeacherConstraint  extends Constraint {
        public CttPlacement[][] iPlacement;
        
        /** Constructor */
        public TeacherConstraint() {
            super();
            iAssignedVariables = null;
            iPlacement = new CttPlacement[iModel.getNrDays()][iModel.getNrSlotsPerDay()];
            for (int d=0;d<iModel.getNrDays();d++)
                for (int s=0;s<iModel.getNrSlotsPerDay();s++)
                    iPlacement[d][s] = null;
            
        }
        
        /** Return placement of a lecture that is taught by this teacher at the given
         * day and time.
         */
        public CttPlacement getPlacement(int d, int s) {
            return iPlacement[d][s];
        }
        
        /** Compute conflict, i.e., another lecture that is taught by this teacher and
         * is placed at the day and time of the given placement.
         */
        public void computeConflicts(Value value, Set conflicts) {
            CttPlacement p = (CttPlacement)value;
            if (iPlacement[p.getDay()][p.getSlot()]!=null && !iPlacement[p.getDay()][p.getSlot()].variable().equals(value.variable()))
                conflicts.add(iPlacement[p.getDay()][p.getSlot()]);
        }
        
        /** Compute conflict, i.e., another lecture that is taught by this teacher and
         * is placed at the day and time of the given placement.
         */
        public boolean inConflict(Value value) {
            CttPlacement p = (CttPlacement)value;
            return iPlacement[p.getDay()][p.getSlot()]!=null && !iPlacement[p.getDay()][p.getSlot()].variable().equals(value.variable());
        }
        
        /** Two lectures that are taught by the same teacher are consistent
         * only when placed at different day or time.
         */
        public boolean isConsistent(Value value1, Value value2) {
            CttPlacement p1 = (CttPlacement)value1;
            CttPlacement p2 = (CttPlacement)value2;
            return p1.getDay()!=p2.getDay() || p1.getSlot()!=p2.getSlot();
        }
        
        /**
         * Update information about placement of lectures of this teacher.
         */
        public void assigned(long iteration, Value value) {
            //super.assigned(iteration, value);
            CttPlacement p = (CttPlacement)value;
            if (iPlacement[p.getDay()][p.getSlot()]!=null) {
                HashSet confs = new HashSet(); confs.add(iPlacement[p.getDay()][p.getSlot()]);
                iPlacement[p.getDay()][p.getSlot()].variable().unassign(iteration);
                iPlacement[p.getDay()][p.getSlot()] = p;
                if (iConstraintListeners!=null)
                    for (Enumeration e=iConstraintListeners.elements();e.hasMoreElements();)
                        ((ConstraintListener)e.nextElement()).constraintAfterAssigned(iteration, this, value, confs);
            } else {
                iPlacement[p.getDay()][p.getSlot()] = p;
            }
        }
        
        /**
         * Update information about placement of lectures of this teacher.
         */
        public void unassigned(long iteration, Value value) {
            //super.unassigned(iteration, value);
            CttPlacement p = (CttPlacement)value;
            iPlacement[p.getDay()][p.getSlot()] = null;
        }
        
        /** String representation */
        public String toString() {
            return CttTeacher.this.toString();
        }
        
        /** Hash code */
        public int hashCode() {
            return CttTeacher.this.hashCode();
        }
    }
    /*Aggiunta classe preferenze*/
    public class TeacherPreference {
        public int day;
        public int slot;
        public int weight;
        private final int WEIGHT_MAP[] = {5,4,3,2,1,1,1,1,1,1};

        public TeacherPreference(int d, int s, int w) {
            day = d;
            slot = s;
            if (w > 10)
                weight = 0;
            else
                weight =  WEIGHT_MAP[w-1];
        }
        public boolean conflictPreference(CttPlacement p) {
            CttLecture lecture = (CttLecture) p.variable();
            if (day == p.getDay() && slot == p.getSlot() && lecture.getCourse().getTeacher().equals(CttTeacher.this))
                return true;
            else
                return false;
        }
        public String toString() {
            return day + " " + slot;
        }
    }

    public void addPreference(int d, int s, int w) {
        iPreferences.add(new TeacherPreference(d,s,w));
    }

    public int getTeacherPenalty(CttPlacement p) {
        int penalty = 0;
        for (int i = 0; i < iPreferences.size(); i++) {
            TeacherPreference tp = (TeacherPreference) iPreferences.elementAt(i);
            //System.out.println("Teacher: "+iId+"Preference:"+tp.day+" "+tp.slot+" "+tp.weight);
            if (tp.conflictPreference(p)) {
                //System.out.println("CONFLITTO!! Placement: "+p.getDay()+" "+p.getSlot());
             penalty += tp.weight;
            }
        }
        return penalty;
    }

    public Vector unsatisfiedPreferences() {
        Vector v = new Vector();
        Vector courses = getCourses();
        for (int i = 0; i < courses.size(); i++) {
            CttCourse course = (CttCourse) courses.elementAt(i);
            for (int j = 0; j < course.getNrLectures(); j++) {
                CttLecture lecture = course.getLecture(j);
                CttPlacement placement = (CttPlacement)lecture.getAssignment();
                if (placement != null) {
                    for (int k = 0; k < iPreferences.size(); k++) {
                        TeacherPreference tp = (TeacherPreference) iPreferences.elementAt(k);
                        if (tp.conflictPreference(placement))
                            v.add(tp);
                    }
                }
            }
        }
        return v;
    }

    private Vector getCourses() {
        Vector v = new Vector();
        for(int i = 0; i < iModel.getCourses().size(); i++) {
            CttCourse course = (CttCourse) iModel.getCourses().elementAt(i);
            if (course.getTeacher() == this)
                v.add(course);
        }
        return v;
    }
}
