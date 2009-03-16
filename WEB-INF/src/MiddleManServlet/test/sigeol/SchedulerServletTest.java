/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package sigeol;

import com.mockrunner.servlet.BasicServletTestCaseAdapter;
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

    public void testServletOutput() throws Exception
    {
        addRequestParameter("course", "test");
        addRequestParameter("inputfile", "testfile");
        addRequestParameter("timeout", "100");
        addRequestParameter("date", "11-03-2009");
        doGet();
        Element root = getOutputAsJDOMDocument().getRootElement();
        assertEquals("html", root.getName());
        //Element head = root.getChild("head");
        System.out.println("pipooooooooooooooo"+root.getValue());
        //Element meta = head.getChild("meta");
        //assertEquals(HttpServletResponse.SC_GONE, meta.getAttributeValue("http-equiv"));

        doPost();
        Element root2 = getOutputAsJDOMDocument().getRootElement();
        assertEquals("html", root2.getName());
        //Element head = root.getChild("head");
        System.out.println("pipooooooooooooooo"+root2.toString());
        assertEquals("","");
        //verifyOutputContains("URL=http://www.mockrunner.com");
    }
}
