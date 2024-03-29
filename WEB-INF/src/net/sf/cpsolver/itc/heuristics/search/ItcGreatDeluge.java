package net.sf.cpsolver.itc.heuristics.search;

import java.text.DecimalFormat;
import java.util.Enumeration;
import java.util.StringTokenizer;
import java.util.Vector;

import org.apache.log4j.Logger;

import net.sf.cpsolver.ifs.extension.Extension;
import net.sf.cpsolver.ifs.heuristics.NeighbourSelection;
import net.sf.cpsolver.ifs.model.Neighbour;
import net.sf.cpsolver.ifs.model.Variable;
import net.sf.cpsolver.ifs.solution.Solution;
import net.sf.cpsolver.ifs.solution.SolutionListener;
import net.sf.cpsolver.ifs.solver.Solver;
import net.sf.cpsolver.ifs.util.DataProperties;
import net.sf.cpsolver.ifs.util.ToolBox;
import net.sf.cpsolver.itc.heuristics.ItcParameterWeightOscillation;
import net.sf.cpsolver.itc.heuristics.ItcParameterWeightOscillation.OscillationListener;
import net.sf.cpsolver.itc.heuristics.neighbour.ItcLazyNeighbour;
import net.sf.cpsolver.itc.heuristics.neighbour.ItcLazyNeighbour.LazyNeighbourAcceptanceCriterion;
import net.sf.cpsolver.itc.heuristics.neighbour.selection.ItcNotConflictingMove;
import net.sf.cpsolver.itc.heuristics.neighbour.selection.ItcSwapMove;
import net.sf.cpsolver.itc.heuristics.search.ItcHillClimber.NeighbourSelector;

/**
 * Great deluge algorithm. A move is accepted if the 
 * overall solution value of the new solution will not exceed 
 * given bound. 
 * <br><br>
 * Bound is initialized to value GreatDeluge.UpperBoundRate &times; value
 * of the best solution. Bound is decreased after each iteration,
 * it is multiplied by GreatDeluge.CoolRate (alternatively, GreatDeluge.CoolRateInv can be 
 * defined, which is GreatDeluge.CoolRate = 1 - (1 / GreatDeluge.CoolRateInv ) ). When
 * a limit GreatDeluge.LowerBoundRate &times; value of the best solution
 * is reached, the bound is increased back to GreatDeluge.UpperBoundRate &times
 * value of the best solution.
 * <br><br>
 * If there was no improvement found between the increments of the bound, the new bound is changed to
 * GreatDeluge.UpperBoundRate^2 with the lower limit set to GreatDeluge.LowerBoundRate^2,
 * GreatDeluge.UpperBoundRate^3 and GreatDeluge.LowerBoundRate^3, etc. till there is an
 * improvement found.
 * <br><br>
 * Custom neighbours can be set using GreatDeluge.Neighbours property that should
 * contain semicolon separated list of {@link NeighbourSelection}. By default, 
 * each neighbour selection is selected with the same probability (each has 1 point in
 * a roulette wheel selection). It can be changed by adding &nbsp;@n at the end
 * of the name of the class, for example:<br>
 * <code>
 * GreatDeluge.Neighbours=net.sf.cpsolver.itc.tim.neighbours.TimRoomMove;net.sf.cpsolver.itc.tim.neighbours.TimTimeMove;net.sf.cpsolver.itc.tim.neighbours.TimSwapMove;net.sf.cpsolver.itc.heuristics.neighbour.selection.ItcSwapMove;net.sf.cpsolver.itc.tim.neighbours.TimPrecedenceMove@0.1
 * </code>
 * <br>
 * Selector TimPrecedenceMove is 10&times; less probable to be selected than other selectors.
 * When GreatDeluge.Random is true, all selectors are selected with the same probability, ignoring these weights.
 * <br><br>
 * When Itc.NextHeuristicsOnReheat parameter is true, a chance is given to another
 * search strategy by returning once null in {@link ItcGreatDeluge#selectNeighbour(Solution)}.
 * When Itc.NextHeuristicsOnReheat.AlterBound is also true, the bound is altered after the null
 * is returned (so that an improvement of the best solution made by some other search
 * strategy is considered as well).
 * <br><br>
 * When GreatDeluge.Update is true, {@link NeighbourSelector#update(Neighbour, long)} is called 
 * after each iteration (on the selector that was used) and roulette wheel selection 
 * that is using {@link NeighbourSelector#getPoints()} is used to pick a selector in each iteration. 
 * See {@link NeighbourSelector} for more details. 
 * 
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
public class ItcGreatDeluge implements NeighbourSelection, SolutionListener, LazyNeighbourAcceptanceCriterion, OscillationListener {
    private static Logger sLog = Logger.getLogger(ItcGreatDeluge.class);
    private static boolean sInfo = sLog.isInfoEnabled();
    private static DecimalFormat sDF2 = new DecimalFormat("0.00");
    private static DecimalFormat sDF5 = new DecimalFormat("0.00000");
    private static DecimalFormat sDF10 = new DecimalFormat("0.0000000000");
    private double iBound = 0.0;
    private double iCoolRate = 0.9999995;
    private long iIter;
    private double iUpperBoundRate = 1.05;
    private double iLowerBoundRate = 0.97;
    private int iMoves = 0;
    private int iAcceptedMoves = 0;
    private int iNrIdle = 0;
    private long iT0 = -1;
    private long iLastImprovingIter = 0;
    private boolean iNextHeuristicsOnReheat = false;
    
    private Vector iNeighbourSelectors = new Vector();
    private boolean iRandomSelection = false;
    private boolean iUpdatePoints = false;
    private double iTotalBonus;
    private boolean iAlterBound = false;
    private boolean iAlterBoundOnReheat = false;

    /**
     * Constructor. Following problem properties are considered:
     * <ul>
     * <li>GreatDeluge.CoolRate ... bound cooling rate (default 0.9999995)
     * <li>GreatDeluge.CoolRateInv ... inverse cooling rate (i.e., GreatDeluge.CoolRate = 1 - (1 / GreatDeluge.CoolRateInv ) )s
     * <li>GreatDeluge.UpperBoundRate ... bound upper bound limit relative to best solution ever found (default 1.05)
     * <li>GreatDeluge.LowerBoundRate ... bound lower bound limit relative to best solution ever found (default 0.97)
     * <li>GreatDeluge.Neighbours ... semicolon separated list of classes implementing {@link NeighbourSelection}
     * <li>GreatDeluge.Random ... when true, a neighbour selector is selected randomly
     * <li>GreatDeluge.Update ... when true, a neighbour selector is selected using {@link ItcHillClimber.NeighbourSelector#getPoints()} weights (roulette wheel selection)
     * <li>Itc.NextHeuristicsOnReheat ... when true, null is returned in {@link ItcGreatDeluge#selectNeighbour(Solution)} once just after a reheat
     * <li>Itc.NextHeuristicsOnReheat.AlterBound ... when true, bound is updated after null is returned
     * </ul>
     * @param properties problem properties
     */    public ItcGreatDeluge(DataProperties properties) throws Exception {
        iCoolRate = properties.getPropertyDouble("GreatDeluge.CoolRate", iCoolRate);
        if (properties.getProperty("GreatDeluge.CoolRateInv")!=null) {
            iCoolRate = 1.0 - (1.0 / properties.getPropertyDouble("GreatDeluge.CoolRateInv", 1.0 / (1.0 - iCoolRate)));
            sLog.info("Cool rate is "+iCoolRate+" (inv:"+properties.getProperty("GreatDeluge.CoolRateInv")+")");
        }
        iUpperBoundRate = properties.getPropertyDouble("GreatDeluge.UpperBoundRate", iUpperBoundRate);
        iLowerBoundRate = properties.getPropertyDouble("GreatDeluge.LowerBoundRate", iLowerBoundRate);
        iNextHeuristicsOnReheat = properties.getPropertyBoolean("Itc.NextHeuristicsOnReheat", iNextHeuristicsOnReheat);
        iAlterBoundOnReheat = properties.getPropertyBoolean("Itc.NextHeuristicsOnReheat.AlterBound", iAlterBoundOnReheat);
        iRandomSelection = properties.getPropertyBoolean("GreatDeluge.Random", iRandomSelection);
        iUpdatePoints = properties.getPropertyBoolean("GreatDeluge.Update", iUpdatePoints);
        String neighbours = properties.getProperty("GreatDeluge.Neighbours",
                ItcSwapMove.class.getName()+"@1;"+
                ItcNotConflictingMove.class.getName()+"@1");
        for (StringTokenizer s=new StringTokenizer(neighbours,";");s.hasMoreTokens();) {
            String nsClassName = s.nextToken();
            double bonus = 1.0;
            if (nsClassName.indexOf('@')>=0) {
                bonus = Double.parseDouble(nsClassName.substring(nsClassName.indexOf('@')+1));
                nsClassName = nsClassName.substring(0, nsClassName.indexOf('@'));
            }
            Class nsClass = Class.forName(nsClassName);
            NeighbourSelection ns = (NeighbourSelection)nsClass.getConstructor(new Class[] {DataProperties.class}).newInstance(new Object[]{properties});
            addNeighbourSelection(ns,bonus);
        }
    }
    
    /** Initialization */
    public void init(Solver solver) {
        iIter = -1;
        solver.currentSolution().addSolutionListener(this);
        for (Enumeration e=solver.getExtensions().elements();e.hasMoreElements();) {
            Extension ext = (Extension)e.nextElement();
            if (ext instanceof ItcParameterWeightOscillation)
                ((ItcParameterWeightOscillation)ext).addOscillationListener(this);
        }
        iTotalBonus = 0;
        for (Enumeration e=iNeighbourSelectors.elements();e.hasMoreElements();) {
            NeighbourSelector s = (NeighbourSelector)e.nextElement();
            s.init(solver);
            iTotalBonus += s.getBonus();
        }
    }
    
    private void addNeighbourSelection(NeighbourSelection ns, double bonus) {
        iNeighbourSelectors.add(new NeighbourSelector(ns, bonus, iUpdatePoints));
    }
    
    private long getTemperatureLength(Solver solver) {
        long len = 0;
        for (Enumeration e=solver.currentSolution().getModel().variables().elements();e.hasMoreElements();) {
            Variable variable = (Variable)e.nextElement();
            len += variable.values().size();
        }
        sLog.info("Temperature length "+len);
        return len;
    }
    
    private double totalPoints() {
        if (!iUpdatePoints) return iTotalBonus;
        double total = 0;
        for (Enumeration e=iNeighbourSelectors.elements();e.hasMoreElements();) {
            NeighbourSelector ns = (NeighbourSelector)e.nextElement();
            total += ns.getPoints();
        }
        return total;
    }
    
    private void info(Solution solution) {
        sLog.info("Iter="+iIter/1000+"k, NonImpIter="+sDF2.format((iIter-iLastImprovingIter)/1000.0)+"k, Speed="+sDF2.format(1000.0*iIter/(System.currentTimeMillis()-iT0))+" it/s");
        sLog.info("Bound is "+sDF2.format(iBound)+", " +
        		"best value is "+sDF2.format(solution.getBestValue())+" ("+sDF2.format(100.0*iBound/solution.getBestValue())+"%), " +
        		"current value is "+sDF2.format(solution.getModel().getTotalValue())+" ("+sDF2.format(100.0*iBound/solution.getModel().getTotalValue())+"%), "+
        		"#idle="+iNrIdle+", "+
        		"Pacc="+sDF5.format(100.0*iAcceptedMoves/iMoves)+"%");
        if (iUpdatePoints)
            for (Enumeration e=iNeighbourSelectors.elements();e.hasMoreElements();) {
                NeighbourSelector ns = (NeighbourSelector)e.nextElement();
                sLog.info("  "+ns+" ("+sDF2.format(ns.getPoints())+" pts, "+sDF2.format(100.0*(iUpdatePoints?ns.getPoints():ns.getBonus())/totalPoints())+"%)");
            }
        iAcceptedMoves = iMoves = 0;
    }
    
    private Neighbour genMove(Solution solution) {
        while (true) {
            if (incIter(solution)) {
                iAlterBound = iAlterBoundOnReheat;
                return null;
            }
            if (iAlterBound) {
                iBound = Math.max(solution.getBestValue()+2.0, Math.pow(iUpperBoundRate,Math.max(1,iNrIdle)) * solution.getBestValue());
                iAlterBound = false;
            }
            NeighbourSelector ns = null;
            if (iRandomSelection) {
                ns = (NeighbourSelector)ToolBox.random(iNeighbourSelectors);
            } else {
                double points = (ToolBox.random()*totalPoints());
                for (Enumeration e=iNeighbourSelectors.elements();e.hasMoreElements();) {
                    ns = (NeighbourSelector)e.nextElement();
                    points -= (iUpdatePoints?ns.getPoints():ns.getBonus());
                    if (points<=0) break;
                }
            }
            Neighbour n = ns.selectNeighbour(solution);
            if (n!=null) return n;
        }
    }
    
    private boolean accept(Solution solution, Neighbour neighbour) {
        if (neighbour instanceof ItcLazyNeighbour) {
            ((ItcLazyNeighbour)neighbour).setAcceptanceCriterion(this);
            return true;
        } else return (neighbour.value()<=0 || solution.getModel().getTotalValue()+neighbour.value()<=iBound);
    }
    
    /** Implementation of {@link net.sf.cpsolver.itc.heuristics.neighbour.ItcLazyNeighbour.LazyNeighbourAcceptanceCriterion} interface */
    public boolean accept(ItcLazyNeighbour neighbour, double value) {
        return (value<=0 || neighbour.getModel().getTotalValue()<=iBound);
    }
    
    private boolean incIter(Solution solution) {
        if (iIter<0) {
            iIter = 0; iLastImprovingIter = 0;
            iT0 = System.currentTimeMillis();
            iBound = iUpperBoundRate * solution.getBestValue();
        } else {
            iIter++; iBound *= iCoolRate;
        }
        if (sInfo && iIter%100000==0) {
            info(solution);
        }
        if (iBound<Math.pow(iLowerBoundRate,1+iNrIdle)*solution.getBestValue()) {
            iNrIdle++;
            sLog.info(" -<["+iNrIdle+"]>- ");
            iBound = Math.max(solution.getBestValue()+2.0, Math.pow(iUpperBoundRate,iNrIdle) * solution.getBestValue());
            return iNextHeuristicsOnReheat;
        }
        return false;
    }
    
    /** Neighbour selection */
    public Neighbour selectNeighbour(Solution solution) {
        Neighbour neighbour = null;
        while ((neighbour=genMove(solution))!=null) {
            iMoves++;
            if (accept(solution,neighbour)) {
                iAcceptedMoves++; break;
            }
        }
        return (neighbour==null?null:neighbour);
    }
    
    public void bestSaved(Solution solution) {
        iNrIdle = 0;
        iLastImprovingIter = iIter;
    }
    public void solutionUpdated(Solution solution) {}
    public void getInfo(Solution solution, java.util.Dictionary info) {}
    public void getInfo(Solution solution, java.util.Dictionary info, java.util.Vector variables) {}
    public void bestCleared(Solution solution) {}
    public void bestRestored(Solution solution){}
    /** Update bound when {@link ItcParameterWeightOscillation} is changed.*/
    public void bestValueChanged(double delta) {
        iBound += delta;
    }
}
