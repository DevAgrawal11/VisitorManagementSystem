package com.verifyVisitor;

import jakarta.servlet.http.HttpSession;

public class SessionUtil {
    
    // Check if user is authenticated
    public static boolean isAuthenticated(HttpSession session) {
        if (session == null) {
            return false;
        }
        
        Boolean isAuthenticated = (Boolean) session.getAttribute("isAuthenticated");
        String empId = (String) session.getAttribute("empId");
        
        return isAuthenticated != null && isAuthenticated && empId != null;
    }
    
    // Get employee ID from session
    public static String getEmployeeId(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("empId");
    }
    
    // Get employee name from session
    public static String getEmployeeName(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("empName");
    }
    
    // Get employee email from session
    public static String getEmployeeEmail(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("empEmail");
    }
    
    // Get employee phone from session
    public static String getEmployeePhone(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("empPhone");
    }
    
    // Get employee department from session
    public static String getEmployeeDepartment(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute("empDepartment");
    }
    
    // Clear all employee data from session
    public static void clearEmployeeData(HttpSession session) {
        if (session != null) {
            session.removeAttribute("empId");
            session.removeAttribute("empName");
            session.removeAttribute("empEmail");
            session.removeAttribute("empPhone");
            session.removeAttribute("empDepartment");
            session.removeAttribute("isAuthenticated");
            session.removeAttribute("loginTime");
            session.removeAttribute("generatedOTP");
            session.removeAttribute("otpMobile");
        }
    }
    
    // Invalidate session completely
    public static void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }
    
    // Check if session has expired (based on login time)
    public static boolean isSessionExpired(HttpSession session, long maxInactiveTime) {
        if (session == null) {
            return true;
        }
        
        Long loginTime = (Long) session.getAttribute("loginTime");
        if (loginTime == null) {
            return true;
        }
        
        long currentTime = System.currentTimeMillis();
        return (currentTime - loginTime) > maxInactiveTime;
    }
    
    // Get session timeout in minutes
    public static int getSessionTimeout(HttpSession session) {
        if (session == null) {
            return 0;
        }
        return session.getMaxInactiveInterval() / 60; // Convert seconds to minutes
    }
    
    // Create employee session after successful authentication
    public static void createEmployeeSession(HttpSession session, Employee employee) {
        session.setAttribute("empId", employee.getEmpId());
        session.setAttribute("empName", employee.getEmpName());
        session.setAttribute("empEmail", employee.getEmpEmail());
        session.setAttribute("empPhone", employee.getEmpMobileNo());
        session.setAttribute("empDepartment", employee.getEmpDepartment());
        session.setAttribute("isAuthenticated", true);
        session.setAttribute("loginTime", System.currentTimeMillis());
    }
}