/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package sigeol;

/**
 *
 * @author mattia
 */
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
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

    String URLName = "http://localhost:8080/timetables";

    public AlgorithmJob() {
    }

    public void execute(JobExecutionContext context) throws JobExecutionException {
        // prelevo il nome del job
        //String jobName = context.getJobDetail().getFullName();

        // prelevo i parametri passati a questo job
        JobDataMap data = context.getJobDetail().getJobDataMap();

        String course = data.getString("course");
        String inFileName = data.getString("input_file");
        String outFileName = data.getString("output_file");
        String timeout = data.getString("timeout");
        //DataOutputStream printout;
        boolean status = false;
        try {
            status = ItcSolver.start(inFileName, outFileName, timeout, null);
        } catch (Exception e) {
        }


        //HttpURLConnection.setFollowRedirects(true);
        //HttpURLConnection con;
        int responseCode = HttpURLConnection.HTTP_UNAVAILABLE;
        for (int i = 0; i < 3 && (responseCode != HttpURLConnection.HTTP_OK); i++) {
            try {
                /*con = (HttpURLConnection) new URL(URLName).openConnection();
                con.setRequestMethod("POST");
                con.setDoOutput(true);
                con.setUseCaches(false);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                // spedisce al server i dati via POST
                printout = new DataOutputStream(con.getOutputStream());
                String status_code = status ? "OK" : "ERROR";
                String content = "course=" + URLEncoder.encode(course, "UTF-8") + "&status=" + URLEncoder.encode(status_code, "UTF-8");
                /*****************************************/
                HttpURLConnection conn = null;
                BufferedReader br = null;
                DataOutputStream dos = null;
                DataInputStream inStream = null;

                InputStream is = null;
                OutputStream os = null;
                boolean ret = false;
                String StrMessage = "";


                String lineEnd = "\r\n";
                String twoHyphens = "--";
                String boundary = "*****";


                int bytesRead, bytesAvailable, bufferSize;

                byte[] buffer;

                int maxBufferSize = 1 * 1024 * 1024;


                String responseFromServer = "";




                //------------------ CLIENT REQUEST
                File outfile = new File(outFileName);
                FileInputStream fileInputStream = new FileInputStream(outfile);

                // open a URL connection to the Servlet

                URL url = new URL(URLName);


                // Open a HTTP connection to the URL

                conn = (HttpURLConnection) url.openConnection();

                // Allow Inputs
                conn.setDoInput(true);

                // Allow Outputs
                conn.setDoOutput(true);

                // Don't use a cached copy.
                conn.setUseCaches(false);

                // Use a post method.
                conn.setRequestMethod("POST");

                conn.setRequestProperty("Connection", "Keep-Alive");

                conn.setRequestProperty("Content-Type", "multipart/form-data;boundary=" + boundary);

                dos = new DataOutputStream(conn.getOutputStream());

                dos.writeBytes(twoHyphens + boundary + lineEnd);
                dos.writeBytes("Content-Disposition: form-data; name=\"upload\";" + " filename=\"" + outfile.getName() + "\"" + lineEnd);
                dos.writeBytes(lineEnd);



                // create a buffer of maximum size

                bytesAvailable = fileInputStream.available();
                bufferSize = Math.min(bytesAvailable, maxBufferSize);
                buffer = new byte[bufferSize];

                // read file and write it into form...

                bytesRead = fileInputStream.read(buffer, 0, bufferSize);

                while (bytesRead > 0) {
                    dos.write(buffer, 0, bufferSize);
                    bytesAvailable = fileInputStream.available();
                    bufferSize = Math.min(bytesAvailable, maxBufferSize);
                    bytesRead = fileInputStream.read(buffer, 0, bufferSize);
                }

                // send multipart form data necesssary after file data...

                dos.writeBytes(lineEnd);
                dos.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

                // close streams

                fileInputStream.close();
                dos.flush();
                dos.close();






                //------------------ read the SERVER RESPONSE



                /****************************************/
                /* printout.writeBytes(content);
                printout.flush();
                printout.close();
                con.setReadTimeout(0);*/
                responseCode = conn.getResponseCode();
            } catch (IOException ex) {
                //Logger.getLogger(AlgorithmJob.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

    }
}
