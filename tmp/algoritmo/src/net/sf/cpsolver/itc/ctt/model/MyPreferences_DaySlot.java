package net.sf.cpsolver.itc.ctt.model;

import java.util.Vector;
import java.util.Iterator;

/* This class is needed for organize course preferences. */

public class MyPreferences_DaySlot {
	
	/* class of a single preference */
	class DaySlot_PreferenceInfo{
		int day;
		int slot;
		int weight;
		String ID_Course;
		
		/* constructor */
		DaySlot_PreferenceInfo(String ID, int d, int s, int p) { day=d; slot=s; weight=p; ID_Course=ID;}

        public boolean equals(Object obj) {
            if ((obj instanceof DaySlot_PreferenceInfo) == false)
                return false;
            DaySlot_PreferenceInfo ds = (DaySlot_PreferenceInfo)obj;
            if (ds.day != day || ds.slot != slot || ds.ID_Course.equals(ID_Course)==false)
                return false;
            return true;
        }
	}
	
	/* array for priority -> weight mapping */
	private int Weight_Map[] = {100,80,65,50,40,30,25,20,15,10};
	/* <Vector> base array for organize course preferences */
	private Vector DaySlot_Preferences;
	
	/* constructor */
	public MyPreferences_DaySlot() {DaySlot_Preferences = new Vector();}
	
	/* getWeightFromPriority: returns the weight associated to a specific priority */
	private int getWeightFromPriority(int priority) { 
		 if (priority>10) return 1;
		 if (priority<=0) return 0;
		 return Weight_Map[priority-1]; 
	}
	/* existsCoursePreference: return true if exists at least one preference about a specific CourseID */
	private boolean existsCoursePreference(String CourseID) {
        for (Iterator it = DaySlot_Preferences.iterator(); it.hasNext();)
            if (((DaySlot_PreferenceInfo)it.next()).ID_Course.equals(CourseID))
                return true;
		return false;
	}	
	/* getPreference: returns a pointer to a DaySlot_PreferenceInfo object specified by a CourseID, a day and a slot */
	private DaySlot_PreferenceInfo getPreference(String CourseID, int day, int slot) {
		for(int i=0; i<DaySlot_Preferences.size(); i++)
			if (((DaySlot_PreferenceInfo)DaySlot_Preferences.elementAt(i)).ID_Course.equals(CourseID) && 
					((DaySlot_PreferenceInfo)DaySlot_Preferences.elementAt(i)).day == day &&
					((DaySlot_PreferenceInfo)DaySlot_Preferences.elementAt(i)).slot == slot ) 
						return (DaySlot_PreferenceInfo)DaySlot_Preferences.elementAt(i);
		return null;
	}
	
	/* Add a preference to preferences vector, input values are: the course ID, the unpreferred day and slot for a lecture of that course */
	public void addPreference(String CourseID, int Day, int Slot, int priority){
		System.out.println(CourseID+" "+Day+" "+Slot);
		DaySlot_PreferenceInfo thisPref = new DaySlot_PreferenceInfo(CourseID, Day, Slot, getWeightFromPriority(priority));
		DaySlot_Preferences.add(thisPref);
	}
	
	/* returns the total penality of the last timetable calculated*/
	/* Each bad lecture assignament (day, slot) of the specified course count as penality */
	public int getPreferencesPenalty(CttCourse course) {
		int penality = 0;
		DaySlot_PreferenceInfo thispref;
		String c_id = course.getId();
		if (existsCoursePreference(c_id))
			for (int i=0; i<course.getNrLectures(); i++) {
	            CttPlacement p = (CttPlacement)course.getLecture(i).getAssignment();
	            if (p!= null) {
	            	thispref = getPreference(c_id, p.getDay(), p.getSlot());
	            	if (thispref!=null)
	            		penality = penality + thispref.weight;
	            }
	        }
        return penality;
	}
	
	
}
