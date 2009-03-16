/*

 */
package sigeol;

/**
 *
 * @author Barbiero Mattia
 * 
 */
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

public class SchedulerJobListener implements Job {


    /**
     * URL per test
     * String URLName = "http://localhost:8080/timetables_test";
     */
    String URLName = "http://localhost:8080/timetables";

    public SchedulerJobListener() {}

    public void execute(JobExecutionContext context) throws JobExecutionException {
        try {
            // prelevo il nome del job
            //String jobName = context.getJobDetail().getFullName();
            // prelevo i parametri passati a questo job
            JobDataMap data = context.getJobDetail().getJobDataMap();
            String course = data.getString("course");

            
            HttpURLConnection.setFollowRedirects(true);
            HttpURLConnection con;
            int responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
            for (int i = 0; i < 3 && (responseCode != HttpURLConnection.HTTP_OK); i++) {
                con = (HttpURLConnection) new URL(URLName).openConnection();
                con.setRequestMethod("POST");
                con.setReadTimeout(0);
                responseCode = con.getResponseCode();
            }
        } catch (Exception ex) {
           Logger.getLogger(SchedulerJobListener.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
