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

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
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
 * @version  1.0
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
    public void execute(JobExecutionContext context) throws JobExecutionException {
        try {
            // parametri passati al job
            int retry = 3;
            JobDataMap data = context.getJobDetail().getJobDataMap();
            String course = data.getString("course");
            String URLName = data.getString("url_client");
            System.out.println("executing job_" + course + " ...");
            HttpURLConnection.setFollowRedirects(true);
            URL url = new URL(URLName+"/"+course+"/notify");
            HttpURLConnection con ;
            int responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
            //for (int i = 0; i < retry && (responseCode != HttpURLConnection.HTTP_OK); i++) {
                con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("POST");
                con.setRequestProperty("course", course);
                con.setReadTimeout(0);
                responseCode = con.getResponseCode();
            //}
        } catch (MalformedURLException ex) {
            Logger.getLogger(SchedulerJobListener.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(SchedulerJobListener.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
