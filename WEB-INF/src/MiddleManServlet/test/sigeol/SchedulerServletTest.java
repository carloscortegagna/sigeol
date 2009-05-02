/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package sigeol;

import com.mockrunner.mock.web.MockHttpServletRequest;
import com.mockrunner.mock.web.MockServletConfig;
import com.mockrunner.mock.web.MockServletContext;
import com.mockrunner.mock.web.WebMockObjectFactory;
import com.mockrunner.servlet.BasicServletTestCaseAdapter;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileUploadTestCase;
import org.jdom.Element;
import org.apache.commons.fileupload.ServletFileUploadTest;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;




public class SchedulerServletTest extends BasicServletTestCaseAdapter
{
    @Override
    protected void setUp() throws Exception
    {
        super.setUp();
        createServlet(SchedulerServlet.class);
        WebMockObjectFactory s =this.getWebMockObjectFactory();
        MockServletConfig config = s.getMockServletConfig();
        MockServletContext context = new MockServletContext();
        context.setContextPath("/home/mattia/progetti/sigeol");
        context.setRealPath("/", "../../..");
        config.setServletContext(context);
        config.setInitParameter("input-itc-path", "/WEB-INF/itc/input/");
        config.setInitParameter("output-itc-path", "/WEB-INF/itc/output/");

    }

    public void testServletGet() throws Exception
    {
        doGet();
        Element root = getOutputAsJDOMDocument().getRootElement();

        assertEquals("HTML page ","html", root.getName().toLowerCase());
        Element head = root.getChild("head");
        Element title = head.getChild("title");
        assertEquals("Sigeol servlet ","sigeol servlet", title.getText().toLowerCase());
    }

     public void testServletNoOperation() throws Exception{
         doPost();
         WebMockObjectFactory s =this.getWebMockObjectFactory();
         assertEquals("Not acceptable operation" , s.getMockResponse().SC_NOT_ACCEPTABLE, s.getMockResponse().getStatusCode());
     }

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

     public void testServletDJOperation() throws Exception{
         addRequestParameter("op", "dj");
         addRequestParameter("course", "test");
         addRequestParameter("timeout", "15");
         File testfile = new File("test.ctt");
                //FileInputStream fileInputStream = new FileInputStream(outfile);
         WebMockObjectFactory s =this.getWebMockObjectFactory();   
    
        String content = "-----1234\r\n" +
                        "Content-Disposition: form-data; name=\"inputfile\"; filename=\"foo.tab\"\r\n" +
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

     public void testServletOtherOperation() throws Exception{
         addRequestParameter("op", "other");
         WebMockObjectFactory s =this.getWebMockObjectFactory();
         doPost();
         assertEquals(s.getMockResponse().SC_NOT_ACCEPTABLE, s.getMockResponse().getStatusCode());
     }
}