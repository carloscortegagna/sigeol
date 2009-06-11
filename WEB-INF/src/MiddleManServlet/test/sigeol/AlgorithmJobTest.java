
package sigeol;

import java.io.File;
import java.io.IOException;
import java.util.Calendar;
import junit.framework.TestCase;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.spi.TriggerFiredBundle;
import org.quartz.xml.CalendarBundle;

/**
 *
 * @author mattia
 */
public class AlgorithmJobTest extends TestCase {
    JobDetail jobDetail ;
    /**
     *
     */
    protected Scheduler scheduler = null;
    
    /**
     *
     * @throws org.quartz.SchedulerException
     */
    @Override
    public void setUp() throws SchedulerException{
         scheduler = StdSchedulerFactory.getDefaultScheduler();  
    }
    
    /**
     *
     * @throws org.quartz.SchedulerException
     */
    public void testRunningJob() throws SchedulerException{
        try {
            File webinf = new File("../..");
            jobDetail = new JobDetail("job_test", "algorithm_job", AlgorithmJob.class);
            jobDetail.getJobDataMap().put("input_file", webinf.getCanonicalPath() + "/itc/input/test.ctt");
            jobDetail.getJobDataMap().put("output_file", webinf.getCanonicalPath() + "/itc/output/");
            jobDetail.getJobDataMap().put("timeout", "50");
            jobDetail.getJobDataMap().put("url_client", "http://localhost:8080/sigeol");
            
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.SECOND, 5);
            //JobExecutionContext context = new JobExecutionContext();
            /** creazione trigger **/
            SimpleTrigger trigger = new SimpleTrigger("trigger_test", "algoritm_trigger", cal.getTime());
            try {
                /** creazione schedulazione **/
                scheduler.scheduleJob(jobDetail, trigger);
            } catch (org.quartz.ObjectAlreadyExistsException exc) {
                /** job già esistente. Eliminazione del job precedente e schedulazione del nuovo **/
                scheduler.deleteJob(jobDetail.getName(), jobDetail.getGroup());
                scheduler.scheduleJob(jobDetail, trigger);
            }
            CalendarBundle calend = new CalendarBundle();
            TriggerFiredBundle bundle = new TriggerFiredBundle(jobDetail, trigger, calend, true, cal.getTime(), null, null, null);
            AlgorithmJob job = new AlgorithmJob();
            JobExecutionContext context = new JobExecutionContext(scheduler, bundle, job);
            job.execute(context);
            assertTrue(true);
            
        } catch (IOException ex) {
            ex.printStackTrace();
            assertTrue(false);
        }
        
    }

}
