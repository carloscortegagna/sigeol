/** TODO controllare se arriva richiesta di un job già schedulato
 **/
package sigeol;

import java.io.FileOutputStream;
import javax.servlet.ServletException;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SimpleTrigger;
import java.util.Calendar;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.ee.servlet.*;


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
import javax.servlet.http.HttpSession;
import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 *
 * @author mattia
 */
public class SchedulerServlet extends HttpServlet{

    protected Scheduler scheduler = null;
    /**
     *
     * @param config
     * @throws javax.servlet.ServletException
     */
    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);

       ServletContext ctx = config.getServletContext();
       System.out.println("Initializing SIGEOL scheduler manager..");
        //StdSchedulerFactory factory = (StdSchedulerFactory) ctx.getAttribute(QuartzInitializerServlet.QUARTZ_FACTORY_KEY);
        try {
            scheduler = StdSchedulerFactory.getDefaultScheduler(); //factory.getScheduler();
            System.out.println("SIGEOL scheduler manager status: OK");
        } catch (Exception e) {
            System.out.println("SIGEOL scheduler manager status: NOT OK");
            e.printStackTrace();
        }
 
    }

    /**
     * Gestisce il metodo HTTP <code>POST</code>.
     * Viene usato per generare l'esecuzione dell'algoritmo
     * @param request servlet request
     * @param response servlet response
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
      response.setContentType("text/html");
      PrintWriter out= response.getWriter();
      out.println("<HTML><head><title>Sigeol Servlet</title></head><BODY BGCOLOR=\"#7F7FFF\"><H1 ALIGN=CENTER>SIGEOL</H1> <br/><h2>Scheduler servlet !</h2></BODY></HTML>");
      out.close();
      doPost(request,response);
    }

    /**
     * Gestisce il metodo HTTP <code>POST</code>.
     * Viene usato per inserire un nuovo evento nello scheduler
     * @param request servlet request
     * @param response servlet response
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // HttpSession session = request.getSession(true);
        //if(!session.isNew())
        String operation = request.getParameter("op");
        if(operation==null){
            response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
            return;
        }
        //Schedule Job
        if(operation.compareTo("sj")==0){
             /** creazione schedulazione job algoritmo **/
             scheduleAlgortihmJob(request, response);
            
        } else
        //Do Job
        if(operation.compareTo("dj")==0){
           /** Controllo POST multipart **/
          boolean isMultipart = ServletFileUpload.isMultipartContent(request);
          System.out.println("ismultipart "+isMultipart);
          if(isMultipart)
                /** inizializzazione e avvio job algoritmo **/
                initAlgortihmJob(request, response);
           else
                response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
        }else
            response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
    }

    /**
     * Ritorna una piccola descrizione della servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Servlet SIGEOL";
    }// </editor-fold>

    private void scheduleAlgortihmJob(HttpServletRequest request, HttpServletResponse response){
        try {
                /** recupero parametri del POST **/
                String course = request.getParameter("course");
                String sdate = request.getParameter("date");
                System.out.println("receiving from POST: "+course+" -- "+sdate);
                /** conversione data da String a Date **/
                java.util.Date date = null;
                String pattern = "dd-MM-yyyy";
                SimpleDateFormat sdf = new SimpleDateFormat(pattern);
                if(sdf.parse(sdate)!=null){
                    long time = sdf.parse(sdate).getTime();
                    date = new java.sql.Date(time);
                }else{
                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.SECOND, 30);
                    date = cal.getTime();
                }
                /** aggiunta dell'evento nello scheduler **/
                if (course != null) {
                    /** creazione del job da schedulare **/
                    JobDetail jobDetail = new JobDetail("job_" + course, "algorithm_job", SchedulerJobListener.class);
                    System.out.println("created job_" + course+" algorithm_job");
                    /** Rendiamo il job recovarable **/
                    jobDetail.setRequestsRecovery(true);
                    /** Rendiamo il job persistente **/
                    //jobDetail.setVolatility(false);
                    /** creazione trigger **/
                    SimpleTrigger trigger = new SimpleTrigger();
                    trigger.setName("trigger_" + course);
                    trigger.setGroup("algoritm_trigger");
                    trigger.setJobGroup("algorithm");
                    trigger.setStartTime(date);

                    System.out.println("created trigger_" + course+" algorithm_trigger");
                    /** creazione evento **/
                    scheduler.scheduleJob(jobDetail, trigger);

                    /** invio risposta di creazione risorsa **/
                    response.setStatus(HttpServletResponse.SC_CREATED);
                } else /** invio risposta di errore **/
                {
                    response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
                }
            } catch (Exception e) {
                   e.printStackTrace();
                /** invio risposta di errore **/
                response.setStatus(HttpServletResponse.SC_EXPECTATION_FAILED);

            }
    }
    private void initAlgortihmJob(HttpServletRequest request, HttpServletResponse response){
            /** lettura file configurazione servlet **/
            ServletConfig cfg = getServletConfig();
            System.out.println("cfg: "+cfg.toString());
            String input_path = cfg.getInitParameter("input-itc-path");
            String output_path = cfg.getInitParameter("output-itc-path");
            try {
                PrintWriter out = null;
                String saveFile = null;

                out = response.getWriter();
                /** salvataggio del file con i parametri del corso**/
                ServletFileUpload upload  = new ServletFileUpload();
                FileItemIterator iter = upload.getItemIterator(request);
                System.out.println("iter: "+iter.toString());

                while (iter.hasNext()) {
                    FileItemStream item = iter.next();
                    String name = item.getFieldName();
                    System.out.println("Name input: "+name);
                    if (name.equals("inputfile") && !item.isFormField()) {
                        DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy-HH:mm:ss");
                        Date date = new java.util.Date();
                        String datetime = dateFormat.format(date);
                        saveFile = input_path + datetime + item.getName();
                        
                        byte[] buffer = new byte[4*1024];
                        /***TEST **/
                        System.out.println("saveFile: "+saveFile+" getcontext: "+getServletContext().getRealPath(saveFile));
                        FileOutputStream fileStream = new FileOutputStream(getServletContext().getRealPath(saveFile));
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
                        out.println("File salvato: " + saveFile);
                    }
                }

                /** recupero parametri del corso **/
                String course = request.getParameter("course");
                String timeout = null;

                /** creazione evento di esecuzione istantanea del job **/
                if (course != null) {
                    timeout = request.getParameter("timeout");
                    if(timeout == null) timeout = "10";
                    /** assegnazione dei parametri al job **/
                    JobDetail jobDetail = new JobDetail("job_" + course, "algorithm_job", AlgorithmJob.class);
                    jobDetail.getJobDataMap().put("input_file", saveFile);
                    jobDetail.getJobDataMap().put("output_file", output_path);
                    jobDetail.getJobDataMap().put("timeout", timeout);
                    /** rendiamo il job ripristinabile **/
                    jobDetail.setRequestsRecovery(true);
                    /** ritardo di 30s all'avvio del job **/
                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.SECOND, 30);

                    /** creazione trigger **/
                    SimpleTrigger trigger = new SimpleTrigger("trigger_" + course, "algoritm_trigger", cal.getTime());

                    /** creazione schedulazione **/
                    scheduler.scheduleJob(jobDetail, trigger);

                    /** invio risposta di esecuzione job **/
                    response.setStatus(HttpServletResponse.SC_GONE);
                    /** TEST **/
                    System.out.println("GONE");

                } else /** invio risposta di errore **/
                {
                    response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
                    /** TEST **/
                    System.out.println("NOT ACCEPTABLE");

                }

            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_EXPECTATION_FAILED);
            }

    }
}
