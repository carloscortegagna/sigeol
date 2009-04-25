/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package sigeol;

import com.mockrunner.mock.web.WebMockObjectFactory;
import com.mockrunner.servlet.BasicServletTestCaseAdapter;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import javax.servlet.http.HttpServletResponse;
import org.jdom.Element;




public class SchedulerServletTest extends BasicServletTestCaseAdapter
{
    @Override
    protected void setUp() throws Exception
    {
        super.setUp();
        createServlet(SchedulerServlet.class);
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
         File testfile = new File("test.ctt");
                //FileInputStream fileInputStream = new FileInputStream(outfile);
         WebMockObjectFactory s =this.getWebMockObjectFactory();
         this.setRequestAttribute("inputfile", testfile);
         s.getMockRequest().setContentType("multipart/form-data");
         //s.getMockRequest().
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
