
package sigeol;

import java.io.File;
import java.io.IOException;
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
public class SchedulerJobListenerTest extends TestCase {
    JobDetail jobDetail ;
    protected Scheduler scheduler = null;
    @Override
    public void setUp() throws SchedulerException{
         scheduler = StdSchedulerFactory.getDefaultScheduler();
    }

    public void testRunningJob() throws SchedulerException{
            
            jobDetail = new JobDetail("jobListener_test", "listener_job", SchedulerJobListener.class);
            jobDetail.getJobDataMap().put("course", "test");
            jobDetail.getJobDataMap().put("url_client", "http://localhost:8080/timetables");
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.SECOND, 5);
            //JobExecutionContext context = new JobExecutionContext();
            /** creazione trigger **/
            SimpleTrigger trigger = new SimpleTrigger("triggerListener_test", "listener_trigger", cal.getTime());
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
    }

}
