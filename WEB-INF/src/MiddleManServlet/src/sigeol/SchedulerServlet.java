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

import java.io.FileOutputStream;
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
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Date;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
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
        out.println("<HTML><head><title>Sigeol Servlet</title></head><BODY BGCOLOR=\"#7F7FFF\"><H1 ALIGN=CENTER>SIGEOL</H1> <br/><h2>Scheduler servlet !</h2></BODY></HTML>");
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
        String operation = request.getParameter("op");
        if (operation == null) {
            response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
            Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error: operation null");
            return;
        }
        //Schedule Job
        if (operation.compareTo("sj") == 0) {
          

            // creazione schedulazione job algoritmo
            scheduleAlgortihmJob(request, response);
        } else {
            // controllo POST multipart
            boolean isMultipart = ServletFileUpload.isMultipartContent(request);
            //Do Job
            if (operation.compareTo("dj") == 0 && isMultipart) // inizializzazione e avvio job algoritmo
            {
                initAlgortihmJob(request, response);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
                Logger.getLogger(SchedulerServlet.class.getName()).log(Level.SEVERE, null, "Error: operation "+operation+" not valid");
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
            System.out.println("receiving from POST: " + course + " -- " + sdate);
            // conversione data da String a Date
            java.util.Date date = null;
            String pattern = "dd-MM-yyyy";
            SimpleDateFormat sdf = new SimpleDateFormat(pattern);
            /*DA RIPRISTINARE
             if (sdf.parse(sdate) != null) {
                long time = sdf.parse(sdate).getTime();
                date = new java.sql.Date(time);
            } else {*/
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.SECOND, 30);
                date = cal.getTime();
            //}
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
    private void initAlgortihmJob(HttpServletRequest request, HttpServletResponse response) {
        Scheduler scheduler = getScheduler(request);

        // lettura file configurazione servlet
        ServletConfig cfg = getServletConfig();

        String input_path = cfg.getInitParameter("input-itc-path");
        String output_path = cfg.getInitParameter("output-itc-path");
        String url_client = cfg.getInitParameter("url-client");
       try {
            String saveFile = null;
            // salvataggio del file con i parametri del corso
            ServletFileUpload upload = new ServletFileUpload();
            FileItemIterator iter = upload.getItemIterator(request);
            
            while (iter.hasNext()) {
                FileItemStream item = iter.next();
                String name = item.getFieldName();
                if (name.equals("inputfile") && !item.isFormField()) {
                    DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy-HH_mm_ss");
                    Date date = new java.util.Date();
                    String datetime = dateFormat.format(date);
                    saveFile = input_path + datetime + "_" + item.getName();

                    byte[] buffer = new byte[4 * 1024];

                    FileOutputStream fileStream = new FileOutputStream(this.getServletContext().getRealPath("/") + saveFile);
                    InputStream stream = item.openStream();
                    int len = 0;
                    while (true) {
                        len = stream.read(buffer);
                        if (len < 0) {
                            break;
                        }
                        fileStream.write(buffer, 0, len);
                    }
                    stream.close();
                    fileStream.flush();
                    fileStream.close();
                }
            }

            // recupero parametri del corso
            String course = request.getParameter("graduate_course");
            String year = request.getParameter("year");
            String subperiod = request.getParameter("subperiod");

            String timeout = null;

            // creazione evento di esecuzione istantanea del job
            if (course != null) {
                timeout = request.getParameter("timeout");
                if (timeout == null) {
                    timeout = "50";
                }
                // assegnazione dei parametri al job
                JobDetail jobDetail = new JobDetail("job_" + course+year+subperiod, "algorithm_job", AlgorithmJob.class);
                jobDetail.getJobDataMap().put("input_file", saveFile);
                jobDetail.getJobDataMap().put("output_file", output_path);
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
                System.out.println("job: " + course + " created. \n Start time: " + trigger.getStartTime().toString());

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
