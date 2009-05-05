
package sigeol;

import java.util.Calendar;
import java.util.List;
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
    protected Scheduler scheduler = null;
    @Override
    public void setUp() throws SchedulerException{
         scheduler = StdSchedulerFactory.getDefaultScheduler();
         
    }
    
    public void testRunningJob() throws SchedulerException{
        jobDetail = new JobDetail("job_test", "algorithm_job", AlgorithmJob.class);
         jobDetail.getJobDataMap().put("input_file", "test.ctt");
         jobDetail.getJobDataMap().put("output_file", "out.ctt");
         jobDetail.getJobDataMap().put("timeout", "20");
         Calendar cal = Calendar.getInstance();
         cal.add(cal.SECOND, 5);
         //JobExecutionContext context = new JobExecutionContext();

         /** creazione trigger **/
         SimpleTrigger trigger = new SimpleTrigger("trigger_test", "algoritm_trigger", cal.getTime());
         try{
                        /** creazione schedulazione **/
                        scheduler.scheduleJob(jobDetail, trigger);

         }catch(org.quartz.ObjectAlreadyExistsException exc){
                        /** job già esistente. Eliminazione del job precedente e schedulazione del nuovo **/
                        scheduler.deleteJob(jobDetail.getName(), jobDetail.getGroup());
                        scheduler.scheduleJob(jobDetail, trigger);
                    }
        List currentjobs = scheduler.getCurrentlyExecutingJobs();
        CalendarBundle calend = new CalendarBundle();
        TriggerFiredBundle bundle = new TriggerFiredBundle(jobDetail,
                          trigger,
                          calend,
                          true,
                          cal.getTime(),
                          null,
                          null,
                          null);
        AlgorithmJob job = new AlgorithmJob();
        JobExecutionContext context = new JobExecutionContext(scheduler,bundle,job); 
       
        job.execute(context);
        System.out.println("size:"+currentjobs.size());
        this.assertFalse("Nessun job in esecuzione", currentjobs.size()==0);
        this.assertFalse("Nessun job in esecuzione", currentjobs.size()==0);

    }

}
