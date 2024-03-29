package net.sf.cpsolver.itc.ctt.neighbours;

import java.util.Enumeration;
import java.util.Vector;

import net.sf.cpsolver.ifs.heuristics.NeighbourSelection;
import net.sf.cpsolver.ifs.model.Neighbour;
import net.sf.cpsolver.ifs.solution.Solution;
import net.sf.cpsolver.ifs.solver.Solver;
import net.sf.cpsolver.ifs.util.DataProperties;
import net.sf.cpsolver.ifs.util.ToolBox;
import net.sf.cpsolver.itc.ctt.model.CttCurricula;
import net.sf.cpsolver.itc.ctt.model.CttLecture;
import net.sf.cpsolver.itc.ctt.model.CttModel;
import net.sf.cpsolver.itc.ctt.model.CttPlacement;
import net.sf.cpsolver.itc.ctt.model.CttRoom;
import net.sf.cpsolver.itc.heuristics.neighbour.ItcSimpleNeighbour;
import net.sf.cpsolver.itc.heuristics.search.ItcHillClimber.HillClimberSelection;

import org.apache.log4j.Logger;

/**
 * Try to find a move that decrease curriculum compactness penalty.
 * A curricula is selected randomly, a lecture that is not adjacent to any other
 * is selected, and placed to some other available time that has an 
 * adjacent lecture (if such placement exists and does not create any conflict).
 * A different room may be assigned to the lecture as well.
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
public class CttCurriculumCompactnessMove implements NeighbourSelection, HillClimberSelection {
    private static Logger sLog = Logger.getLogger(CttCurriculumCompactnessMove.class);
    private boolean iHC = false;
    
    /** Constructor */
    public CttCurriculumCompactnessMove(DataProperties properties) {}
    /** Initialization */
    public void init(Solver solver) {}
    /** Set hill-climber mode (worsening moves are skipped) */
    public void setHcMode(boolean hcMode) { iHC = hcMode; }
    
    /** Neighbour selection */
    public Neighbour selectNeighbour(Solution solution) {
        CttModel model = (CttModel)solution.getModel();
        if (model.getCompactPenalty(false)<=0) return null;
        int cx = ToolBox.random(model.getCurriculas().size());
        for (int c=0;c<model.getCurriculas().size();c++) {
            CttCurricula curricula = (CttCurricula)model.getCurriculas().elementAt((c+cx)%model.getCurriculas().size());
            Vector adepts = new Vector();
            for (int d=0;d<model.getNrDays();d++) {
                for (int s=0;s<model.getNrSlotsPerDay();s++) {
                    CttPlacement p = curricula.getConstraint().getPlacement(d, s);
                    if (p==null) continue;
                    CttPlacement prev = (s==0?null:curricula.getConstraint().getPlacement(d, s-1));
                    CttPlacement next = (s+1==model.getNrSlotsPerDay()?null:curricula.getConstraint().getPlacement(d, s+1));
                    if (next==null && prev==null) {
                        adepts.add(p);
                    }
                }
            }
            if (!adepts.isEmpty()) {
                int ax = ToolBox.random(adepts.size());
                for (int a=0;a<adepts.size();a++) {
                    CttPlacement adept = (CttPlacement)adepts.elementAt((a+ax)%adepts.size());
                    Neighbour n = findNeighbour(curricula, adept);
                    if (n!=null) return n;
                }
            }
        }
        return null;
    }
    
    private Neighbour findNeighbour(CttCurricula curricula, CttPlacement placement) {
        int compactPenalty = placement.getCompactPenalty();
        CttModel model = (CttModel)placement.variable().getModel();
        int dx = ToolBox.random(model.getNrDays());
        int sx = ToolBox.random(model.getNrSlotsPerDay());
        for (int d=0;d<model.getNrDays();d++) {
            int day = (d+dx) % model.getNrDays();
            for (int s=0;s<model.getNrSlotsPerDay();s++) {
                int slot = (s+sx) % model.getNrSlotsPerDay();
                if (curricula.getConstraint().getPlacement(day, slot)!=null) continue;
                CttPlacement prev = (slot==0?null:curricula.getConstraint().getPlacement(day, slot-1));
                CttPlacement next = (slot+1==model.getNrSlotsPerDay()?null:curricula.getConstraint().getPlacement(day, slot+1));
                if ((next==null || next.equals(placement)) && (prev==null || prev.equals(placement))) continue;
                Neighbour n = findNeighbour((CttLecture)placement.variable(), compactPenalty, day, slot, placement.getRoom());
                if (n!=null) return n;
            }
        }
        return null;
    }    
    
    private Neighbour findNeighbour(CttLecture lecture, int compactPenalty, int day, int slot, CttRoom originalRoom) {
        if (!lecture.getCourse().isAvailable(day,slot)) return null;
        if (lecture.getCourse().getTeacher().getConstraint().getPlacement(day,slot)!=null) return null;
        for (Enumeration e=lecture.getCourse().getCurriculas().elements();e.hasMoreElements();) {
            CttCurricula curricula = (CttCurricula)e.nextElement();
            if (curricula.getConstraint().getPlacement(day,slot)!=null) return null;
        }
        if ((CttPlacement)originalRoom.getConstraint().getPlacement(day, slot)==null) {
            CttPlacement newPlacement = new CttPlacement(lecture, originalRoom, day, slot);
            int compactPenaltyChange = newPlacement.getCompactPenalty() - compactPenalty;
            ItcSimpleNeighbour n = new ItcSimpleNeighbour(lecture, newPlacement);
            if ((!iHC || n.value()<=0) && compactPenaltyChange<0) return n;
        }
        int rx = ToolBox.random(lecture.getCourse().getModel().getRooms().size());
        for (int r=0;r<lecture.getCourse().getModel().getRooms().size();r++) {
            CttRoom room = (CttRoom)lecture.getCourse().getModel().getRooms().elementAt((r+rx)%lecture.getCourse().getModel().getRooms().size());
            if (room.getSize()<lecture.getCourse().getNrStudents()) continue;
            /*add*/
            if (!(room.getType().equals(lecture.getCourse().getType()))) continue;
            if ((CttPlacement)room.getConstraint().getPlacement(day, slot)==null) {
                CttPlacement newPlacement = new CttPlacement(lecture, room, day, slot);
                int compactPenaltyChange = newPlacement.getCompactPenalty() - compactPenalty;
                ItcSimpleNeighbour n = new ItcSimpleNeighbour(lecture, newPlacement);
                if (iHC && n.value()>0) continue;
                if (compactPenaltyChange<0) return n;
            }
        }
        return null;
    }
    
}