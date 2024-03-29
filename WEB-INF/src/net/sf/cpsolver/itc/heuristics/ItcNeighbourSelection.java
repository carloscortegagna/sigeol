package net.sf.cpsolver.itc.heuristics;

import org.apache.log4j.Logger;

import net.sf.cpsolver.ifs.heuristics.NeighbourSelection;
import net.sf.cpsolver.ifs.heuristics.StandardNeighbourSelection;
import net.sf.cpsolver.ifs.heuristics.ValueSelection;
import net.sf.cpsolver.ifs.heuristics.VariableSelection;
import net.sf.cpsolver.ifs.model.Neighbour;
import net.sf.cpsolver.ifs.solution.Solution;
import net.sf.cpsolver.ifs.solver.Solver;
import net.sf.cpsolver.ifs.util.DataProperties;
import net.sf.cpsolver.itc.ItcModel;
import net.sf.cpsolver.itc.heuristics.search.ItcHillClimber;
import net.sf.cpsolver.itc.heuristics.search.ItcTabuSearch;
import net.sf.cpsolver.itc.heuristics.search.ItcGreatDeluge;

/**
 * Core search strategy for all three tracks of the ITC 2007.
 * <br><br>
 * At first, a complete solution is to be found using
 * {@link StandardNeighbourSelection} with {@link ItcUnassignedVariableSelection} as 
 * variable selection criterion and {@link ItcTabuSearch} as value selection criterion.
 * A weight of a value can be set for this phase using Itc.Construction.ValueWeight 
 * parameter. Neighbour selection can be redefined using Itc.Construction parameter
 * (contains fully qualified class name of a {@link NeighbourSelection}), or just variable
 * selection or value selection criterion can be redefined using parameters
 * Itc.ConstructionValue and Itc.ConstructionVariable.
 * <br><br>
 * Once a complete solution is found (construction neigbhour selection returns null), two (or
 * three) neighbour selections are rotated. Each selection is used till it returns null 
 * value in {@link NeighbourSelection#selectNeighbour(Solution)}. Once it happens next selection
 * starts to be used for selection (up till it returns null as well). When the last neighbour selection
 * is used and exhausted, first selection starts to be used again.
 * <br><br>
 * First neighbour selection is {@link ItcHillClimber} and it can be redefined by Itc.First parameter.<br>
 * Second neighbour selection is {@link ItcGreatDeluge} and it can be redefined by Itc.Second parameter.<br>
 * Thidr neighbour selection can be set using Itc.Third parameter and it is not defined by default. Also note
 * that by default, {@link ItcGreatDeluge} never returns null. 
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
public class ItcNeighbourSelection extends StandardNeighbourSelection {
    private static Logger sLog = Logger.getLogger(ItcNeighbourSelection.class);
    private int iPhase = 0;
    private NeighbourSelection iConstruct, iFirst, iSecond, iThird;
    
    /** Constructor */
    public ItcNeighbourSelection(DataProperties properties) throws Exception {
        super(properties);
        
        double valueWeight = properties.getPropertyDouble("Itc.Construction.ValueWeight", 0);
        iConstruct = 
            (NeighbourSelection)
            Class.forName(properties.getProperty("Itc.Construction",StandardNeighbourSelection.class.getName())).
            getConstructor(new Class[] {DataProperties.class}).
            newInstance(new Object[] {properties});
        if (iConstruct instanceof StandardNeighbourSelection) {
            StandardNeighbourSelection std = (StandardNeighbourSelection)iConstruct;
            std.setValueSelection(
                    (ValueSelection)
                    Class.forName(properties.getProperty("Itc.ConstructionValue",ItcTabuSearch.class.getName())).
                    getConstructor(new Class[] {DataProperties.class}).
                    newInstance(new Object[] {properties}));
            std.setVariableSelection(
                    (VariableSelection)
                    Class.forName(properties.getProperty("Itc.ConstructionVariable",ItcUnassignedVariableSelection.class.getName())).
                    getConstructor(new Class[] {DataProperties.class}).
                    newInstance(new Object[] {properties}));
            try {
                std.
                    getValueSelection().
                    getClass().
                    getMethod("setValueWeight", new Class[] {double.class}).
                    invoke(std.getValueSelection(), new Object[] {new Double(valueWeight)});
            } catch (NoSuchMethodException e) {}
        }
        try {
            iConstruct.
                getClass().
                getMethod("setValueWeight", new Class[] {double.class}).
                invoke(iConstruct, new Object[] {new Double(valueWeight)});
        } catch (NoSuchMethodException e) {}
        
        iFirst = (NeighbourSelection)
            Class.forName(properties.getProperty("Itc.First",ItcHillClimber.class.getName())).
            getConstructor(new Class[] {DataProperties.class}).
            newInstance(new Object[] {properties});
        
        iSecond = (NeighbourSelection)
            Class.forName(properties.getProperty("Itc.Second",ItcGreatDeluge.class.getName())).
            getConstructor(new Class[] {DataProperties.class}).
            newInstance(new Object[] {properties});
        
        if (properties.getProperty("Itc.Third")!=null)
            iThird = (NeighbourSelection)Class.forName(properties.getProperty("Itc.Third")).
                getConstructor(new Class[] {DataProperties.class}).
                newInstance(new Object[] {properties});
    }
    
    /** Initialization */
    public void init(Solver solver) {
        super.init(solver);
        iConstruct.init(solver);
        iFirst.init(solver);
        iSecond.init(solver);
        if (iThird!=null) iThird.init(solver);
    }
    
    /** Change phase, i.e., what selector is to be used next */
    protected void incPhase(Solution solution, String name) {
        iPhase ++;
        if (sLog.isInfoEnabled()) {
            ItcModel m = (ItcModel)solution.getModel();
            sLog.info("**CURR["+solution.getIteration()+"]** P:"+Math.round(m.getTotalValue())+
                    " ("+m.csvLine()+")");
            sLog.info("Phase "+name);
        }
    }
    
    /** Neighbour selection  -- based on the phase, construction strategy is used first,
     * than it iterates between two or three given neighbour selections*/
    public Neighbour selectNeighbour(Solution solution) {
        Neighbour n = null;
        switch (iPhase) {
            case 0 :
                n = iConstruct.selectNeighbour(solution);
                if (n!=null) return n;
                incPhase(solution, "first");
            case 1 :
                n = iFirst.selectNeighbour(solution);
                if (n!=null) return n;
                incPhase(solution, "second");
            case 2 :
                n = iSecond.selectNeighbour(solution);
                if (n!=null) return n;
                incPhase(solution, "third");
            case 3 :
                n = (iThird==null?null:iThird.selectNeighbour(solution));
                if (n!=null) return n;
                incPhase(solution, "first");
            default :
                iPhase = 1;
                return selectNeighbour(solution);
        }
    }

}
