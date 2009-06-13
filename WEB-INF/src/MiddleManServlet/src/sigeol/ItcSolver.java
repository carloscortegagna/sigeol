/*
 * Copyright 2008-2009 QuiXoft
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 */


package sigeol;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;

import java.util.Enumeration;
import java.util.Hashtable;
import net.sf.cpsolver.ifs.solution.Solution;
import net.sf.cpsolver.ifs.solution.SolutionListener;
import net.sf.cpsolver.ifs.solver.Solver;
import net.sf.cpsolver.ifs.util.DataProperties;
import net.sf.cpsolver.ifs.util.JProf;
import net.sf.cpsolver.ifs.util.Progress;
import net.sf.cpsolver.ifs.util.ToolBox;
import net.sf.cpsolver.itc.ItcModel;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

/**
 * <p>
 * <code>ItcSolver</code> si occupa di eseguire l'algoritmo, mediante l'utilizzo
 * della libreria Cpsolver, per la generazione degli orari sulla base della
 * configurazione scritta su file di input.
 *
 * </p>
 *
 * @see net.sf.cpsolver.ifs.solution.Solution;
 * @see net.sf.cpsolver.ifs.solution.SolutionListener;
 * @see net.sf.cpsolver.ifs.solver.Solver;
 * @see net.sf.cpsolver.ifs.util.DataProperties;
 * @see net.sf.cpsolver.ifs.util.JProf;
 * @see net.sf.cpsolver.ifs.util.Progress;
 * @see net.sf.cpsolver.ifs.util.ToolBox;
 * @see net.sf.cpsolver.itc.ItcModel;
 * @author Mattia Barbiero
 * @version  1.1
 *
 *
 */
public class ItcSolver {
    private static String sProblem = null;
    private static File sInputFile = null;
    private static File sOutputFile = null;
    private static File sCSVFile = null;
    private static File sLogFile = null;
    private static File sPropertyFile = null;
    private static long sSeed = generateSeed();
    private static long sTimeOut = -1;
    private static DataProperties sConfig = new DataProperties();
    private static Logger sLog = Logger.getLogger(ItcSolver.class);

    /** Generate random seed
     * @return
     */
    public static long generateSeed() {
        //return System.currentTimeMillis();
        return Math.round(Long.MAX_VALUE * Math.random());
    }

    /** Setup Log4j logging
     * @param logFile 
     * @param info
     * @param debug
     */
    public static void setupLogging(File logFile, boolean info, boolean debug) {
        Logger root = Logger.getRootLogger();
        ConsoleAppender console = new ConsoleAppender(new PatternLayout("%m%n"));//%-5p %c{1}> %m%n
        console.setThreshold(info?Level.INFO:Level.WARN);
        root.addAppender(console);
        Logger.getLogger(JProf.class).setLevel(Level.ERROR);
        if (info || debug) {
            try {
                FileAppender file = new FileAppender(
                    new PatternLayout("%d{dd-MMM-yy HH:mm:ss.SSS} [%t] %-5p %c{2}> %m%n"),
                    logFile.getPath(),
                    false);
                file.setThreshold(Level.DEBUG);
                root.addAppender(file);
            } catch (IOException e) {
                sLog.fatal("Unable to configure logging, reason: "+e.getMessage(), e);
            }
        }
        if (!debug) root.setLevel(info?Level.INFO:Level.WARN);
    }

    
    /** Parse input arguments
     * @param inputFile
     * @param outputFile
     * @param maxTime
     * @param seed
     * @return
     */
    public static boolean init(String inputFile,String outputFile, String maxTime, String seed) {
        if (inputFile == null) {
            return false;
        }
        sProblem = "ctt";
        sInputFile = new File(inputFile);
        if (!sInputFile.exists()) {
            System.err.println("Input file '"+sInputFile+"' does not exist.");
            return false;
        }
        if(seed!=null)
            sSeed = Long.parseLong(seed);
        else
            sSeed = generateSeed();
        if(maxTime!=null)
            sTimeOut = Long.parseLong(maxTime);
        else sTimeOut=Long.parseLong(System.getProperty("timeout", String.valueOf(sTimeOut)));
        if (ItcSolver.class.getResource("/"+sProblem+".properties")!=null) {
            try {
                sConfig.load(ItcSolver.class.getResourceAsStream("/"+sProblem+".properties"));
            } catch (IOException e) {
                System.err.println("Unable to read property file, reason: "+e.getMessage());
                e.printStackTrace(System.err);
            }
        }
        sConfig.putAll(System.getProperties());
        String ext = sConfig.getProperty("Model.Extension","out");

        /*if (args.length>=3) {
            sOutputFile = new File(args[2]);
            if (sOutputFile.exists() && sOutputFile.isDirectory()) {
                String name = sInputFile.getName();
                if (name.indexOf('.')>=0) name=name.substring(0, name.lastIndexOf('.'));
                sOutputFile = new File(sOutputFile, name+"_"+sSeed+"."+ext);
            }
        } else {*/
            String name = sInputFile.getName();
            if (name.indexOf('.')>=0) name=name.substring(0, name.lastIndexOf('.'));
            sOutputFile = new File(outputFile, name+"."+ext);
        //}
        if (sOutputFile.getParentFile()!=null) sOutputFile.getParentFile().mkdirs();

        sLogFile = new File(sOutputFile.getParentFile(), sOutputFile.getName().substring(0,sOutputFile.getName().lastIndexOf('.'))+".log");
        boolean debug = "debug".equals(System.getProperty("verbose"));
        boolean info = debug || "info".equals(System.getProperty("verbose"));
        setupLogging(sLogFile, info, debug);

        sCSVFile = new File(sOutputFile.getParentFile(),sInputFile.getName().substring(0, sInputFile.getName().lastIndexOf('.'))+".csv");

        ToolBox.setSeed(sSeed);
        sConfig.setProperty("General.Seed", String.valueOf(sSeed));
        sConfig.setProperty("General.Input", sInputFile.getPath());
        sConfig.setProperty("General.Output", sOutputFile.getPath());
        if (sTimeOut>=0)
            sConfig.setProperty("Termination.TimeOut", String.valueOf(sTimeOut));
        else
            sTimeOut = sConfig.getPropertyLong("Termination.TimeOut", -1);

        sLog.info("Problem: "+sProblem);
        sLog.info("Input:   "+sInputFile);
        sLog.info("Output:  "+sOutputFile);
        sLog.info("CSV:     "+sCSVFile);
        sLog.info("Log:     "+sLogFile);
        sLog.info("Seed:    "+sSeed);
        sLog.info("Timeout: "+sTimeOut);

        return true;
    }

    /** Create solver instance */
    private static Solver create() throws Exception {
        ItcModel model = (ItcModel)Class.forName(sConfig.getProperty("Model.Class")).newInstance();
        model.setProperties(sConfig);
        if (!model.load(sInputFile)) {
            sLog.error("Unable to load input file.");
            return null;
        }

        Solver solver = new Solver(sConfig);
        Solution solution = new Solution(model);
        solver.setInitalSolution(solution);

        solver.currentSolution().addSolutionListener(new SolutionListener() {
            public void solutionUpdated(Solution solution) {}
            public void getInfo(Solution solution, java.util.Dictionary info) {}
            public void getInfo(Solution solution, java.util.Dictionary info, java.util.Vector variables) {}
            public void bestCleared(Solution solution) {}
            public void bestSaved(Solution solution) {
                ItcModel m = (ItcModel)solution.getModel();
                sLog.info("**BEST["+solution.getIteration()+"]** V:"+m.nrAssignedVariables()+"/"+m.variables().size()+", P:"+Math.round(m.getTotalValue())+" ("+m.csvLine()+")");
            }
            public void bestRestored(Solution solution) {}
        });

        return solver;
    }

    /** Solve problem
     * @return
     */
    public static Solution solve() {
        try {
            Solver solver = create();

            solver.start();
            try {
                solver.getSolverThread().join();
            } catch (InterruptedException e) {}

            Solution solution = solver.currentSolution();
            solution.restoreBest();
            ((ItcModel)solution.getModel()).makeFeasible();
            solution.saveBest();

            return output(solver);
        } catch (Exception e) {
            sLog.error("Unable to solve problem, reason: "+e.getMessage(),e);
        }
        return null;
    }

    /** Output solution and some additional information */
    private static Solution output(Solver solver) throws Exception {
        Solution solution = solver.lastSolution();
        ItcModel model = (ItcModel)solution.getModel();
        Progress.removeInstance(model);
        if (solution.getBestInfo()==null) {
            sLog.error("No best solution found.");
            return null;
        }
        solution.restoreBest();

        sLog.info("Best solution:"+ToolBox.dict2string(solution.getExtendedInfo(),1));

        sLog.info("Best solution found after "+solution.getBestTime()+" seconds ("+solution.getBestIteration()+" iterations).");
        sLog.info("Number of assigned variables is "+solution.getModel().assignedVariables().size());
        sLog.info("Total value of the solution is "+solution.getModel().getTotalValue());

        if (sOutputFile!=null && !model.save(sOutputFile)) {
            sLog.error("Unable to save solution.");
        }

        if (sCSVFile!=null && model.cvsPrint()) {
            boolean ex = sCSVFile.exists();
            PrintWriter w = new PrintWriter(new FileWriter(sCSVFile,true));
            if (!ex)
                w.println("seed,timeout,time,iter,total,"+model.csvHeader());
            ItcModel m = (ItcModel)solution.getModel();
            DecimalFormat df = new DecimalFormat("0.00");
            w.println(
                    sSeed+","+
                    sTimeOut+","+
                    df.format(solution.getBestTime())+","+
                    solution.getBestIteration()+","+
                    Math.round(m.getTotalValue()+5000*m.unassignedVariables().size())+","+
                    model.csvLine());
            w.flush(); w.close();
        }

        return solution;
    }

    /** Stop solver and output solution when Ctrl^C is pressed. *
    private static class ShutdownHook extends Thread {
        Solver iSolver = null;
        public ShutdownHook(Solver solver) {
            setName("ShutdownHook");
            iSolver = solver;
        }
        @Override
        public void run() {
            try {
                if (iSolver.isRunning()) iSolver.stopSolver();

                Solution solution = iSolver.currentSolution();
                solution.restoreBest();
                ((ItcModel)solution.getModel()).makeFeasible();
                solution.saveBest();

                output(iSolver);
            } catch (Exception e) {
                sLog.error("Unable to solve problem, reason: "+e.getMessage(),e);
            }
        }
    }
*/
    /** Test given instance, return best found solution
     * @param instance
     * @param seed
     * @param properties
     * @param timeout
     * @return
     *
    public static Solution test(String instance, DataProperties properties, long seed, long timeout) {
        ToolBox.setSeed(seed);
        properties.setProperty("General.Seed", String.valueOf(seed));
        properties.setProperty("General.Input", instance);
        properties.remove("General.Output");
        properties.setProperty("Termination.TimeOut", String.valueOf(timeout));
        sSeed = seed;
        sTimeOut = timeout;
        sConfig = properties;
        sCSVFile = null;
        sInputFile = new File(instance);
        sOutputFile = null;
        sLogFile = null;
        Solution solution = solve();
        return solution;
    }*/

    /** Main method -- parse input arguments, create solver, solve, and output solution on exit
     * @param inputFile
     * @param timeout
     * @param outputFile
     * @param seed
     * @return
     */
    public static File start(String inputFile,String outputFile, String timeout, String seed) {
       
        try {
            if (init(inputFile,outputFile, timeout, seed)) {
               Solution s = solve();
                //ItcModel m = (ItcModel)s.getModel();
                //Hashtable hash = m.getInfo();
                //controllo Assigned variables: 100.00%
                //String result = String.valueOf(hash.get("Assigned variables"));
                //if(result.indexOf("100.00%") == -1)
                   // sOutputFile=null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            sLog.error("Unable to solve problem, reason: "+e.getMessage(),e);
        }finally{
            return sOutputFile;
        }
    }

}

