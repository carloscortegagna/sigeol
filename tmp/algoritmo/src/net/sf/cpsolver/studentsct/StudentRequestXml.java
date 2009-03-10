package net.sf.cpsolver.studentsct;

import java.io.File;
import java.io.FileOutputStream;
import java.text.DecimalFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.Iterator;

import net.sf.cpsolver.coursett.Constants;
import net.sf.cpsolver.ifs.util.DataProperties;
import net.sf.cpsolver.ifs.util.ToolBox;
import net.sf.cpsolver.studentsct.model.Course;
import net.sf.cpsolver.studentsct.model.CourseRequest;
import net.sf.cpsolver.studentsct.model.Enrollment;
import net.sf.cpsolver.studentsct.model.FreeTimeRequest;
import net.sf.cpsolver.studentsct.model.Request;
import net.sf.cpsolver.studentsct.model.Section;
import net.sf.cpsolver.studentsct.model.Student;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.XMLWriter;

/**
 * This class exports student course and free time requests in a format as defined in this
 * <a href='http://www.unitime.org/interface/StudentSectioning.dtd'>Student Sectioning DTD</a>. 
 * See this <a href='http://www.unitime.org/interface/studentSectioningRequest.xml'>example</a> file.
 *
 * @version
 * StudentSct 1.1 (Student Sectioning)<br>
 * Copyright (C) 2007 Tomas Muller<br>
 * <a href="mailto:muller@unitime.org">muller@unitime.org</a><br>
 * Lazenska 391, 76314 Zlin, Czech Republic<br>
 * <br>
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * <br><br>
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * <br><br>
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

public class StudentRequestXml {
    private static DecimalFormat s2zDF = new DecimalFormat("00");
    
    public static Document exportModel(StudentSectioningModel model) {
        Document document = DocumentHelper.createDocument();
        Element requestElement = document.addElement("request");
        requestElement.addAttribute("campus", model.getProperties().getProperty("Data.Initiative"));
        requestElement.addAttribute("year", model.getProperties().getProperty("Data.Year"));
        requestElement.addAttribute("term", model.getProperties().getProperty("Data.Term"));
        for (Enumeration e=model.getStudents().elements();e.hasMoreElements();) {
            Student student = (Student)e.nextElement();
            Element studentElement = requestElement.addElement("student");
            studentElement.addAttribute("key",String.valueOf(student.getId()));
            Element courseRequestsElement = studentElement.addElement("updateCourseRequests");
            courseRequestsElement.addAttribute("commit", "true");
            Collections.sort(student.getRequests(),new Comparator() {
               public int compare(Object o1, Object o2) {
                   Request r1 = (Request)o1;
                   Request r2 = (Request)o2;
                   if (r1.isAlternative()!=r2.isAlternative()) {
                       return (r1.isAlternative()?1:-1);
                   }
                   return Double.compare(r1.getPriority(), r2.getPriority());
               }
            });
            boolean hasSchedule = false;
            for (Enumeration f=student.getRequests().elements();f.hasMoreElements();) {
                Request request = (Request)f.nextElement();
                if (request.getAssignment()!=null) hasSchedule = true;
                if (request instanceof FreeTimeRequest) {
                    FreeTimeRequest ftReq = (FreeTimeRequest)request;
                    Element ftReqElement = courseRequestsElement.addElement("freeTime");
                    requestElement.addAttribute("days", ftReq.getTime().getDayHeader());
                    int startSlot = ftReq.getTime().getStartSlot();
                    int startTime = startSlot*Constants.SLOT_LENGTH_MIN+Constants.FIRST_SLOT_TIME_MIN;
                    ftReqElement.addAttribute("startTime", s2zDF.format(startTime/60)+s2zDF.format(startTime%60));
                    int endTime = startTime + ftReq.getTime().getLength()*Constants.SLOT_LENGTH_MIN - ftReq.getTime().getBreakTime();
                    ftReqElement.addAttribute("endTime", s2zDF.format(endTime/60)+s2zDF.format(endTime%60));
                    ftReqElement.addAttribute("length", String.valueOf(ftReq.getTime().getLength()*Constants.SLOT_LENGTH_MIN));
                } else {
                    CourseRequest crReq = (CourseRequest)request;
                    Element crReqElement = courseRequestsElement.addElement("courseOffering");
                    Course course = (Course)crReq.getCourses().firstElement();
                    crReqElement.addAttribute("subjectArea", course.getSubjectArea());
                    crReqElement.addAttribute("courseNumber", course.getCourseNumber());
                    crReqElement.addAttribute("waitlist", crReq.isWaitlist()?"true":"false");
                    crReqElement.addAttribute("alternative", crReq.isAlternative()?"true":"false");
                    for (int i=1;i<crReq.getCourses().size();i++) {
                        Course altCourse = (Course)crReq.getCourses().elementAt(i);
                        Element altCourseElement = crReqElement.addElement("alternative");
                        altCourseElement.addAttribute("subjectArea",altCourse.getSubjectArea());
                        altCourseElement.addAttribute("courseNumber",altCourse.getCourseNumber());
                    }
                }
            }
            if (hasSchedule) {
                Element requestScheduleElement = studentElement.addElement("requestSchedule");
                requestScheduleElement.addAttribute("type", "commit");
                for (Enumeration f=student.getRequests().elements();f.hasMoreElements();) {
                    Request request = (Request)f.nextElement();
                    if (request instanceof CourseRequest) {
                        CourseRequest crReq = (CourseRequest)request;
                        Enrollment enrollment = (Enrollment)crReq.getAssignment();
                        if (enrollment==null) continue;
                        Element crReqElement = requestScheduleElement.addElement("courseOffering");
                        Course course = enrollment.getConfig().getOffering().getCourse(student);
                        crReqElement.addAttribute("subjectArea", course.getSubjectArea());
                        crReqElement.addAttribute("courseNumber", course.getCourseNumber());
                        for (Iterator i=enrollment.getAssignments().iterator();i.hasNext();) {
                            Section section = (Section)i.next();
                            Element classEl = crReqElement.addElement("class");
                            classEl.addAttribute("id", section.getSubpart().getInstructionalType());
                            classEl.addAttribute("assignmentId", String.valueOf(section.getId()));
                        }
                    }
                }                
            }
        }
        return document;
    }
    
    public static void main(String[] args) {
        try {
            ToolBox.configureLogging();
            StudentSectioningModel model = new StudentSectioningModel(new DataProperties());
            StudentSectioningXMLLoader xmlLoad = new StudentSectioningXMLLoader(model);
            xmlLoad.setInputFile(new File(args[0]));
            xmlLoad.load();
            Document document = exportModel(model);
            FileOutputStream fos = new FileOutputStream(new File(args[1]));
            (new XMLWriter(fos,OutputFormat.createPrettyPrint())).write(document);
            fos.flush();
            fos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}