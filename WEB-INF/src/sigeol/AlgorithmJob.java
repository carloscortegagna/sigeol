/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package sigeol;

/**
 *
 * @author mattia
 */
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;

import java.net.URL;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

public class AlgorithmJob implements Job {

    public AlgorithmJob() {
    }

    public void execute(JobExecutionContext context) throws JobExecutionException {
        // prelevo il nome del job
        //String jobName = context.getJobDetail().getFullName();

        // prelevo i parametri passati a questo job
        JobDataMap data = context.getJobDetail().getJobDataMap();

        String course = data.getString("course");
        String fileName = data.getString("input_file");
        String timeout = data.getString("timeout");
        DataOutputStream printout;
        boolean status = false;
        try {
            status = ItcSolver.start(fileName, timeout, null);
        } catch (Exception e) {}

        String URLName = "http://localhost:8080/timetables";
        HttpURLConnection.setFollowRedirects(true);
        HttpURLConnection con;
        int responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
        for (int i = 0; i < 3 && (responseCode != HttpURLConnection.HTTP_OK); i++) {
            try {
                con = (HttpURLConnection) new URL(URLName).openConnection();
                con.setRequestMethod("POST");                
                con.setDoOutput(true);
                con.setUseCaches(false);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                // spedisce al server i dati via POST
                printout = new DataOutputStream(con.getOutputStream());
                String status_code = status ? "OK" : "ERROR";
                String content = "course=" + URLEncoder.encode(course, "UTF-8") + "&status=" + URLEncoder.encode(status_code, "UTF-8");
                printout.writeBytes(content);
                printout.flush();
                printout.close();
                con.setReadTimeout(0);
                responseCode = con.getResponseCode();
            } catch (IOException ex) {
                Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

    }
}
