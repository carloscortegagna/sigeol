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
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;
import org.quartz.ee.servlet.QuartzInitializerServlet;
import java.util.Calendar;
import org.quartz.impl.StdSchedulerFactory;
import java.text.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * <p>
 * <code>SchedulerServlet</code> implementa le funzionalita di una http servlet.
 * Viene utilizzata per ascoltare ed eseguire le richieste da parte
 * dell'applicazione Sigeol
 * </p>
 *
 * @see org.quartz.Scheduler
 * @see org.quartz.Job
 * @see org.quartz.Trigger
 * @see sigeol.AlgorithmJob
 * @see sigeol.SchedulerJobListener
 * @author Mattia Barbiero
 * @version  2.0
 *
 * 
 */
public class SchedulerServlet extends HttpServlet {

    /**
     * <p>
     * Inizializza la servlet e lo scheduler basato su Quartz
     * </p>
     *
     * @param config
     * @throws ServletException
     */
    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        Logger.getLogger(SchedulerServlet.class.getName()).log(Level.INFO, null, "Servlet SIGEOL initialized");
    }

    /**<p>
     * Gestisce il metodo HTTP <code>GET</code>.
     * Visualizza solamente una pagina col nome del progetto
     * </p>
     * @param request servlet request
     * @param response servlet response
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<HTML><head><title>Sigeol Servlet</title></head><BODY BGCOLOR=\"#CCCCFF\"><H1 ALIGN=CENTER>SIGEOL</H1> <br/><h2>Scheduler servlet <br>Installazione effettuata con successo!</h2></BODY></HTML>");
        out.close();        
    }

    /**<p>
     * Gestisce il metodo HTTP <code>POST</code>.
     * Viene usato per inserire un nuovo evento nello scheduler o iniziare
     * l'esecuzione di un job
     * </p>
     * @param request servlet request
     * @param response servlet response
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        //HttpSession session = request.getSession(true);
        //if(!session.isNew())
        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (isMultipart){
            initAlgortihmJob(request, response);
        } else {
             String operation = request.getParameter("op");
             if (operation == null) {
                response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
                Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error: operation null");
                return;
             }
             if (operation.compareTo("sj") == 0) {
            // creazione schedulazione job algoritmo
                scheduleAlgortihmJob(request, response);
            }
        }
    }

    /**<p>
     * Ritorna una piccola descrizione della servlet.
     * </p>
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Servlet SIGEOL";
    }

    /**<p>
     * Crea una schedulazione per un determinato corso
     * </p>
     * @param request servlet request
     * @param response servlet response
     */
    private void scheduleAlgortihmJob(HttpServletRequest request, HttpServletResponse response) {
        Scheduler scheduler = getScheduler(request);
        try {
            // lettura file configurazione servlet
            ServletConfig cfg = getServletConfig();
            String url_client = cfg.getInitParameter("url-client");
            
            // recupero parametri del POST
            String course = request.getParameter("graduate_course");
            String sdate = request.getParameter("date");
            String year = request.getParameter("year");
            String subperiod = request.getParameter("subperiod");
            // conversione data da String a Date
            java.util.Date date = null;
            String pattern = "dd-MM-yyyy";
            SimpleDateFormat sdf = new SimpleDateFormat(pattern);
            if (sdate != null && sdf.parse(sdate) != null) {
                long time = sdf.parse(sdate).getTime();
                date = new java.sql.Date(time);
            } else {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.SECOND, 30);
                date = cal.getTime();
            }
            // aggiunta dell'evento nello scheduler
            if (course != null) {
                // creazione del job da schedulare
                JobDetail jobDetail = new JobDetail("jobListener_" + course+year+subperiod, "listener_job", SchedulerJobListener.class);
                System.out.println("created job_" + course + " listener_job");
                jobDetail.getJobDataMap().put("url_client", url_client);
                jobDetail.getJobDataMap().put("course", course);
                jobDetail.getJobDataMap().put("year", year);
                jobDetail.getJobDataMap().put("subperiod", subperiod);
                // rendiamo il job recovarable
                jobDetail.setRequestsRecovery(true);
                // rendiamo il job persistente
                jobDetail.setVolatility(false);
                // creazione trigger
                SimpleTrigger trigger = new SimpleTrigger();
                trigger.setName("triggerListener_" + course+year+subperiod);
                trigger.setGroup("listener_trigger");
                trigger.setJobGroup("algorithm");
                trigger.setStartTime(date);
                trigger.setVolatility(false);
                System.out.println("created triggerListener_" + course + " listener_trigger");
                // creazione evento
                scheduler.scheduleJob(jobDetail, trigger);
                // invio risposta di creazione risorsa
                response.setStatus(HttpServletResponse.SC_CREATED);
            } else // invio risposta di errore
            {
                response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
                Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error creating job: course not valid");

            }
        } catch (Exception e) {
            e.printStackTrace();
            // invio risposta di errore
            response.setStatus(HttpServletResponse.SC_EXPECTATION_FAILED);
            Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, e.toString());
        }
    }

    /**<p>
     * Avvia l'esecuzione del calcolo dell'orario di un determinato corso
     * </p>
     * @param request servlet request
     * @param response servlet response
     */
    private void initAlgortihmJob(HttpServletRequest request, HttpServletResponse response)  {
        Scheduler scheduler = getScheduler(request);
        System.out.println("init algo");
        // lettura file configurazione servlet
        ServletConfig cfg = getServletConfig();
        // recupero parametri del corso
        String op="";
        String course="";
        String year="";
        String subperiod="";
        String input_path = cfg.getInitParameter("input-itc-path");
        String output_path = cfg.getInitParameter("output-itc-path");
        String url_client = cfg.getInitParameter("url-client");
       try {
            String saveFile = null;
            // salvataggio del file con i parametri del corso
            // Create a factory for disk-based file items
            DiskFileItemFactory factory = new DiskFileItemFactory();

            // Set factory constraints
            factory.setSizeThreshold(DiskFileItemFactory.DEFAULT_SIZE_THRESHOLD);

            factory.setRepository(new File(this.getServletContext().getRealPath("/")));

            ServletFileUpload upload = new ServletFileUpload(factory);
            List  items = upload.parseRequest(request);
            Iterator iter = items.iterator();

            //FileItemIterator iter = upload.getItemIterator(request);
            while (iter.hasNext()) {
                FileItem item = (FileItem)iter.next();

                if (item.isFormField())
                {
                    String name = item.getFieldName();
                    if (name.equals("op") )
                        op = item.getString();
                    if (name.equals("graduate_course") )
                        course = item.getString();
                    if (name.equals("year") )
                        year=item.getString();
                    if (name.equals("subperiod"))
                        subperiod = item.getString();
                }
                if (!(item.isFormField()))
                {
                    DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy-HH_mm_ss");
                    Date date = new java.util.Date();
                    String datetime = dateFormat.format(date);
                    saveFile = input_path + datetime + "_" + subperiod+course+".ctt";
                    saveFile= this.getServletContext().getRealPath("/")+saveFile;
                    File uploadedFile = new File(saveFile);
                    item.write(uploadedFile);
                }
            }
            
            String timeout = null;

            // creazione evento di esecuzione istantanea del job
            if (!course.equals("")) {
                timeout = request.getParameter("timeout");
                if (timeout == null) {
                    timeout = "50";
                }
                // assegnazione dei parametri al job
                JobDetail jobDetail = new JobDetail("job_" + course+year+subperiod, "algorithm_job", AlgorithmJob.class);
                jobDetail.getJobDataMap().put("input_file", saveFile);
                jobDetail.getJobDataMap().put("output_file", this.getServletContext().getRealPath("/")+output_path);
                jobDetail.getJobDataMap().put("url_client", url_client);
                jobDetail.getJobDataMap().put("timeout", timeout);
                jobDetail.getJobDataMap().put("year", year);
                jobDetail.getJobDataMap().put("subperiod", subperiod);
                jobDetail.getJobDataMap().put("course", course);

                // rendiamo il job ripristinabile
                jobDetail.setRequestsRecovery(true);
                jobDetail.setVolatility(false);
                // ritardo di 30s all'avvio del job
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.SECOND, 30);
                // creazione trigger
                SimpleTrigger trigger = new SimpleTrigger("trigger_" + course+year+subperiod, "algoritm_trigger", cal.getTime());
                try {
                    // creazione schedulazione
                    scheduler.scheduleJob(jobDetail, trigger);
                } catch (org.quartz.ObjectAlreadyExistsException exc) {
                    // job già esistente. Eliminazione del job precedente e schedulazione del nuovo
                    scheduler.deleteJob(jobDetail.getName(), jobDetail.getGroup());
                    scheduler.scheduleJob(jobDetail, trigger);
                }
                // invio risposta di esecuzione job
                response.setStatus(HttpServletResponse.SC_GONE);
                
            } else // invio risposta di errore
            {
                response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
                Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error creating job: course null");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_EXPECTATION_FAILED);
            e.printStackTrace();
            Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error creating job: "+e.toString());
        }
    }

     /**<p>
     * Ritorna un riferimento all'istanza scheduler
     * </p>
      * @param request servlet request     *
      * @return
     */
    public Scheduler getScheduler(HttpServletRequest request) {
        try {
            ServletContext ctx = request.getSession().getServletContext();
            StdSchedulerFactory factory = (StdSchedulerFactory) ctx.getAttribute(QuartzInitializerServlet.QUARTZ_FACTORY_KEY);
            return factory.getScheduler();
        } catch (SchedulerException ex) {
            Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error getting scheduler istance "+ex.toString());
            return null;
        }
    }
}
