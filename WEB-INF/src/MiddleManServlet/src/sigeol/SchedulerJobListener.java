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


import java.io.DataOutputStream;
import java.io.IOException;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;


/**
 * <p>
 * <code>SchedulerJobListener</code> si occupa di segnalare all'applicazione
 * Sigeol che deve essere eseguita la generazione dell'orario per un determinato
 * corso
 * </p>
 *
 * @see org.quartz.Job
 * @see org.quartz.Trigger
 * @see sigeol.SchedulerServlet
 * @author Mattia Barbiero
 * @version  1.3
 *
 *
 */
public class SchedulerJobListener implements Job {

    /**
     *
     */
    public SchedulerJobListener() {
    }

    /**
     * <p>
     * Segnala l'evento all'applicazione Sigeol
     * </p>
     *
     * @param context
     * @throws JobExecutionException
     */
    @SuppressWarnings("static-access")
    public void execute(JobExecutionContext context) throws JobExecutionException {
        try {
            // parametri passati al job
            int retry = 1;
            JobDataMap data = context.getJobDetail().getJobDataMap();
            String course = data.getString("course");
            String URLName = data.getString("url_client");
            String year = data.getString("year");
            String subperiod = data.getString("subperiod");
            System.out.println("executing job_" + course + " ...");
            URL url ;
            HttpURLConnection con ;
            DataOutputStream    printout;

            int responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
            
            url = new URL(URLName+"/timetables/notify");
            
            responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
            for (int i = 0; i < retry ; i++) {
             /*   if(i>0)
                    try {
                        Thread.currentThread().sleep(10000*i);
                    } catch (InterruptedException ex) {
                        Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
                    }
              */
                con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("POST");
                con.setDoInput (true);
                // Let the RTS know that we want to do output.
                con.setDoOutput (true);
                // No caching, we want the real thing.
                con.setUseCaches (false);
                // Specify the content type.
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                // Send POST output.
                printout = new DataOutputStream (con.getOutputStream ());
                String content = "graduate_course=" + URLEncoder.encode (course) +
                "&year=" + URLEncoder.encode (year)+"&subperiod=" + URLEncoder.encode (subperiod);
                printout.writeBytes (content);
                printout.flush ();
                printout.close ();
                con.setReadTimeout(0);
                responseCode = con.getResponseCode();
            }
            System.out.println(URLName+"/timetables"+"/notify"+": responseCode "+responseCode);

        } catch (MalformedURLException ex) {
            Logger.getLogger(SchedulerJobListener.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(SchedulerJobListener.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
