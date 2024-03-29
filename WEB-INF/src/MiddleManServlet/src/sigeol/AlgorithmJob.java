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
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
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
 * <code>AlgorithmJob</code> si occupa di eseguire l'algoritmo per la
 * generazione degli orari sulla base della configurazione scritta su file di
 * input.
 * Inoltre comunica il risultato all'applicazione Sigeol inviando un file con il
 * risultato dell'operazione.
 * </p>
 * 
 * @see org.quartz.Job
 * @see org.quartz.Trigger
 * @see sigeol.SchedulerServlet
 * @see sigeol.ItcSolver
 * @author Mattia Barbiero
 * @version  1.3
 *
 *
 */
public class AlgorithmJob implements Job {

    /**
     * <p>
     * Create a  AlgorithmJob instance
     * </p>
     */
    public AlgorithmJob() {
    }

    /**
     * <p>
     * Esegue l'algoritmo e richiama il metodo <code>sendResult</code> per
     * l'invio del risultato
     * </p>
     *
     * @param context
     * @throws JobExecutionException
     */
    @SuppressWarnings("static-access")
    public void execute(JobExecutionContext context) throws JobExecutionException {
        // recupero parametri passati al job 
        JobDataMap data = context.getJobDetail().getJobDataMap();
        String inFileName = data.getString("input_file");
        String outFileName = data.getString("output_file");
        String timeout = data.getString("timeout");
        
        // utilizzo dell'algoritmo
        try {
            File outfile = ItcSolver.start(inFileName, outFileName, timeout, null);                  
            if(outfile==null)
                outfile = new File(outFileName+"error.out");
            else{
                String csv = outfile.getName();
                System.out.println(csv);
                csv = csv.replace("out", "csv");
                File csvoutfile = new File(outFileName+csv);
                csvoutfile.delete();
            }
            sendResult(outfile, context);
            File sInputFile = new File(inFileName);
            sInputFile.delete();
            outfile.delete();
        } catch (Exception e) {
            Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, "Errore algorithm job: "+e.toString());
            return;
        }
    }

     /**
     * <p>
     * Invia il risultato all'applicazione Sigeol
     * </p>
     *
     * @param String outFileName
     *          Nome del file contente il risultato
     * @param String URLName
     *          URL dell'applicazione <code>Sigeol</code>
     * @param  String course
     *          Nome del corso
     */
    @SuppressWarnings("static-access")
    private void sendResult(File outFileName, JobExecutionContext context) {
        JobDataMap data = context.getJobDetail().getJobDataMap();
        String course = data.getString("course");
        String URLName = data.getString("url_client");
        String year = data.getString("year");
        String subperiod = data.getString("subperiod");

        FileInputStream fileInputStream = null;
        try {
            int responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
            HttpURLConnection conn = null;
            DataOutputStream dos = null;
            String lineEnd = "\r\n";
            String twoHyphens = "--";
            String boundary = "*****";
            int bytesRead;
            int bytesAvailable;
            int bufferSize;
            byte[] buffer;
            int retry = 1;
            int maxBufferSize = 1 * 1024 * 1024;
            File outfile = outFileName;
            fileInputStream = new FileInputStream(outfile);
            URL url;
            HttpURLConnection con ;

            url = new URL(URLName+"/timetables/done");
            for (int i = 0; i < retry ; i++) {
                /*if(i>0)
                    try {
                        Thread.currentThread().sleep(10000*i);
                    } catch (InterruptedException ex) {
                        Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
                    }*/
                // connessione HTTP all'applicazione Sigeol
                conn = (HttpURLConnection) url.openConnection();
                // permette input
                conn.setDoInput(true);
                // permette output
                conn.setDoOutput(true);
                // cache disabilitata
                conn.setUseCaches(false);
                // utilizzo metodo POST
                conn.setReadTimeout(0);
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Connection", "Keep-Alive");
                conn.setRequestProperty("Content-Type", "multipart/form-data;boundary=" + boundary);
                dos = new DataOutputStream(conn.getOutputStream());
                dos.writeBytes(twoHyphens + boundary + lineEnd);
                dos.writeBytes("Content-Disposition: form-data; name=\"inputfile\";" + " filename=\"" + outfile.getName() + "\"" + lineEnd);
                dos.writeBytes(lineEnd);
                // crea buffer di dimensioni massime
                bytesAvailable = fileInputStream.available();
                bufferSize = Math.min(bytesAvailable, maxBufferSize);
                buffer = new byte[bufferSize];
                // legge il file e lo scrive nel form
                bytesRead = fileInputStream.read(buffer, 0, bufferSize);
                while (bytesRead > 0) {
                    dos.write(buffer, 0, bufferSize);
                    bytesAvailable = fileInputStream.available();
                    bufferSize = Math.min(bytesAvailable, maxBufferSize);
                    bytesRead = fileInputStream.read(buffer, 0, bufferSize);

                }

                // conclude la creazione del form multipart
                dos.writeBytes(lineEnd);
                dos.writeBytes(twoHyphens + boundary + lineEnd);
                dos.writeBytes("Content-Disposition: form-data; name=\"graduate_course\"" + lineEnd);
                dos.writeBytes(lineEnd);
                dos.writeBytes(course + lineEnd);
                dos.writeBytes(twoHyphens + boundary + lineEnd);
                dos.writeBytes("Content-Disposition: form-data; name=\"year\"" + lineEnd);
                dos.writeBytes(lineEnd);
                dos.writeBytes(year + lineEnd);
                dos.writeBytes(twoHyphens + boundary + lineEnd);
                dos.writeBytes("Content-Disposition: form-data; name=\"subperiod\"" + lineEnd);
                dos.writeBytes(lineEnd);
                dos.writeBytes(subperiod + lineEnd);
                dos.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);
                
                dos.flush();
                dos.close();
                responseCode = conn.getResponseCode();
               
            }


            System.out.println(URLName+"/timetables"+"/done"+": responseCode "+responseCode);

            // chiude gli stream
                fileInputStream.close();

        } catch (MalformedURLException ex) {
            Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
        }

    }
}
