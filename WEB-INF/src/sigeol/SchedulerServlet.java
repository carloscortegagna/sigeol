/** TODO controllare se arriva richiesta di un job già schedulato
 se cron uguale nn modifica, se diversa sostituisce
 
 **/

package sigeol;

import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SimpleTrigger;
import java.util.Calendar;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.ee.servlet.*;


import java.text.*;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author mattia
 */
public class SchedulerServlet extends HttpServlet {

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
        StdSchedulerFactory factory = (StdSchedulerFactory) ctx.getAttribute(QuartzInitializerServlet.QUARTZ_FACTORY_KEY);
        try {
            scheduler = factory.getScheduler();
        } catch (Exception e) {
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
        try {
            /** recupero parametri del GET **/
            String course = request.getParameter("course");
            String file = request.getParameter("inputfile");
            String timeout = request.getParameter("timeout");

            /** creazione evento di esecuzione istantanea del job **/
            if(file != null && timeout != null && course != null){

                /** assegnazione dei parametri al job **/
                JobDetail jobDetail = new JobDetail("job_"+course,"algorithm_job",AlgorithmJob.class);
                jobDetail.getJobDataMap().put("input_file", file);
                jobDetail.getJobDataMap().put("timeout", timeout);

                /** ritardo di 30s all'avvio del job **/
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.SECOND, 30);

                /** creazione dell'evento **/
                SimpleTrigger trigger = new SimpleTrigger("trigger_"+course,"algoritm_trigger", cal.getTime());

                /** creazione evento **/
                scheduler.scheduleJob(jobDetail,trigger);

                /** invio risposta di esecuzione job **/
                response.sendError(HttpServletResponse.SC_GONE);

            }else                
                /** invio risposta di errore **/
                response.sendError(HttpServletResponse.SC_NOT_ACCEPTABLE);

        } catch (Exception e) {
            /** invio risposta di errore **/
                response.sendError(HttpServletResponse.SC_EXPECTATION_FAILED);
        } 
    }

    /** 
     * Gestisce il metodo HTTP <code>POST</code>.
     * Viene usato per inserire un nuovo evento nello scheduler
     * @param request servlet request
     * @param response servlet response
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException{
        try {
            /** recupero parametri del POST **/
            String course = request.getParameter("course");
            String sdate = request.getParameter("date");

            /** conversione data da String a Date **/
            java.sql.Date date = null;
            String pattern = "dd/MM/yyyy";
            SimpleDateFormat sdf = new SimpleDateFormat(pattern);
            date = new java.sql.Date(sdf.parse(sdate).getTime());

            /** aggiunta dell'evento nello scheduler **/
            if(date != null && course != null){

                /** creazione del job da schedulare **/
                JobDetail jobDetail = new JobDetail("job_"+course,"algorithm_job",SchedulerJobListener.class);

                /** creazione trigger **/
                SimpleTrigger trigger = new SimpleTrigger();
                trigger.setName("trigger_"+course);
                trigger.setGroup("algoritm_trigger");
                trigger.setJobGroup("algorithm");
                trigger.setStartTime(date);

                /** creazione evento **/
                scheduler.scheduleJob(jobDetail,trigger);

                /** invio risposta di creazione risorsa **/
                response.sendError(HttpServletResponse.SC_CREATED);

            }else
                /** invio risposta di errore **/
                response.sendError(HttpServletResponse.SC_NOT_ACCEPTABLE);            
        } catch (Exception e) {

            /** invio risposta di errore **/
            response.sendError(HttpServletResponse.SC_EXPECTATION_FAILED);

        } 
    }   

    /** 
     * Ritorna una piccola descrizione della servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Servlet per la schedulazione di lavori";
    }// </editor-fold>
}
