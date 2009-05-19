/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package sigeol;

import com.mockrunner.mock.web.MockServletConfig;
import com.mockrunner.mock.web.MockServletContext;
import com.mockrunner.mock.web.WebMockObjectFactory;
import com.mockrunner.servlet.BasicServletTestCaseAdapter;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.jdom.Element;
import org.quartz.Scheduler;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.ee.servlet.QuartzInitializerServlet;



/**
 *
 * @author mattia
 */
public class SchedulerServletTest extends BasicServletTestCaseAdapter
{
    @Override
    protected void setUp() throws Exception
    {

        super.setUp();
        createServlet(org.quartz.ee.servlet.QuartzInitializerServlet.class);
        createServlet(SchedulerServlet.class);
        WebMockObjectFactory s =this.getWebMockObjectFactory();
        MockServletConfig config = s.getMockServletConfig();
        MockServletContext context = new MockServletContext();
        context.setContextPath("/home/mattia/progetti/sigeol");
        context.setRealPath("/", "../../..");
        config.setServletContext(context);
        config.setInitParameter("input-itc-path", "/WEB-INF/itc/input/");
        config.setInitParameter("output-itc-path", "/WEB-INF/itc/output/");
        config.setInitParameter("shutdown-on-unload", "true");
        config.setInitParameter("start-scheduler-on-load", "true");
        config.setInitParameter("url-client","http://localhost:8080/sigeol/timetables");
    }

    /**
     *
     * @throws java.lang.Exception
     */
    public void testServletGet() throws Exception
    {
        doGet();
        Element root = getOutputAsJDOMDocument().getRootElement();

        assertEquals("HTML page ","html", root.getName().toLowerCase());
        Element head = root.getChild("head");
        Element title = head.getChild("title");
        assertEquals("Sigeol servlet ","sigeol servlet", title.getText().toLowerCase());
    }

    /**
     *
     * @throws java.lang.Exception
     */
    public void testServletNoOperation() throws Exception{
         doPost();
         WebMockObjectFactory s =this.getWebMockObjectFactory();
         assertEquals("Not acceptable operation" , s.getMockResponse().SC_NOT_ACCEPTABLE, s.getMockResponse().getStatusCode());
     }

     /**
      *
      * @throws java.lang.Exception
      */
     public void testServletSJOperation() throws Exception{
         Calendar cal = Calendar.getInstance();
         cal.add(Calendar.SECOND, 30);

         String pattern = "dd-MM-yyyy";
         SimpleDateFormat sdf = new SimpleDateFormat(pattern);
         addRequestParameter("op", "sj");
         addRequestParameter("course", "test");
         addRequestParameter("date",sdf.format(cal.getTime()));

         doPost();
         WebMockObjectFactory s =this.getWebMockObjectFactory();
         assertEquals(s.getMockResponse().SC_CREATED, s.getMockResponse().getStatusCode());
         //assertEquals(s.getMockResponse().SC_NOT_ACCEPTABLE, s.getMockResponse().getStatusCode());
         //assertEquals(s.getMockResponse().SC_EXPECTATION_FAILED, s.getMockResponse().getStatusCode());
     }

     /**
      *
      * @throws java.lang.Exception
      */
     public void testServletDJOperation() throws Exception{
         addRequestParameter("op", "dj");
         addRequestParameter("course", "test");
         addRequestParameter("timeout", "15");
         File testfile = new File("test.ctt");
                //FileInputStream fileInputStream = new FileInputStream(outfile);
         WebMockObjectFactory s =this.getWebMockObjectFactory();   
    
        String content = "-----1234\r\n" +
                        "Content-Disposition: form-data; name=\"inputfile\"; filename=\"test.ctt\"\r\n" +
                        "Content-Type: text/whatever\r\n" +
                        "\r\n" +
                        "This is the content of the file\n" +
                        "\r\n" +
                        "-----1234\r\n" +
                        "Content-Disposition: form-data; name=\"field\"\r\n" +
                         "\r\n" +
                         "fieldValue\r\n" +
                         "-----1234\r\n" +
                         "Content-Disposition: form-data; name=\"multi\"\r\n" +
                          "\r\n" +
                         "value1\r\n" +
                          "-----1234\r\n" +
                         "Content-Disposition: form-data; name=\"multi\"\r\n" +
                         "\r\n" +
                         "value2\r\n" +
                         "-----1234--\r\n";
         byte[] bytes = content.getBytes("US-ASCII");
         String contentType = "multipart/form-data; boundary=---1234";
         s.getMockRequest().setContentType(contentType);
         s.getMockRequest().setBodyContent(bytes);

         s.getMockRequest().setContextPath("/");
         s.getMockRequest().setServletPath("/");
         doPost();         
         assertEquals(s.getMockResponse().SC_GONE, s.getMockResponse().getStatusCode());
     }

     /**
      *
      * @throws java.lang.Exception
      */
     public void testServletOtherOperation() throws Exception{
         addRequestParameter("op", "other");
         WebMockObjectFactory s =this.getWebMockObjectFactory();
         doPost();
         assertEquals(s.getMockResponse().SC_NOT_ACCEPTABLE, s.getMockResponse().getStatusCode());
     }
}