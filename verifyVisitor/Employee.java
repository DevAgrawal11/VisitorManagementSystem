package com.verifyVisitor;

public class Employee {
    private String empId;
    private String empName;
    private String empEmail;
    private String empDepartment;
    private String empMobileNo;
    private String flag;
    
    // Default constructor
    public Employee() {}
    
    // Parameterized constructor
    public Employee(String empId, String empName, String empEmail, String empDepartment, String empMobileNo, String flag) {
        this.empId = empId;
        this.empName = empName;
        this.empEmail = empEmail;
        this.empDepartment = empDepartment;
        this.empMobileNo = empMobileNo;
        this.flag = flag;
    }
    
    // Getters and Setters
    public String getEmpId() {
        return empId;
    }
    
    public void setEmpId(String empId) {
        this.empId = empId;
    }
    
    public String getEmpName() {
        return empName;
    }
    
    public void setEmpName(String empName) {
        this.empName = empName;
    }
    
    public String getEmpEmail() {
        return empEmail;
    }
    
    public void setEmpEmail(String empEmail) {
        this.empEmail = empEmail;
    }
    
    public String getEmpDepartment() {
        return empDepartment;
    }
    
    public void setEmpDepartment(String empDepartment) {
        this.empDepartment = empDepartment;
    }
    
    public String getEmpMobileNo() {
        return empMobileNo;
    }
    
    public void setEmpMobileNo(String empMobileNo) {
        this.empMobileNo = empMobileNo;
    }
    
    public String getFlag() {
        return flag;
    }
    
    public void setFlag(String flag) {
        this.flag = flag;
    }
    
    @Override
    public String toString() {
        return "Employee{" +
                "empId='" + empId + '\'' +
                ", empName='" + empName + '\'' +
                ", empEmail='" + empEmail + '\'' +
                ", empDepartment='" + empDepartment + '\'' +
                ", empMobileNo='" + empMobileNo + '\'' +
                ", flag='" + flag + '\'' +
                '}';
    }
}