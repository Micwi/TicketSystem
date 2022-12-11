//
//  AdminViewExistingDepartments.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 12/6/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class AdminViewExistingDepartments: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //database connection variable
    private let database = Firestore.firestore()

    //reference to tableview used in app screen
    @IBOutlet weak var existingDepartmentsTableView: UITableView!
    
    //array of custom struct type to hold all data for each department
    static var existingDepartments = [ExistingDepartmentDataForCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.grabExistingDepartmentData()
        existingDepartmentsTableView.delegate = self
        existingDepartmentsTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.existingDepartmentsTableView.reloadData()
    }
    //method to grab department name and ID and set to variables
    func grabExistingDepartmentData(){
        AdminViewExistingDepartments.existingDepartments = [ExistingDepartmentDataForCell]()
        self.database.collection("Departments").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //variable to hold current department name
                var currentDepartmentName = ""
                //variable to hold the current department ID
                var currentDepartmentID = ""
                for document in querySnapshot!.documents {
                    let data = document.data()
                    currentDepartmentName = data["Department Name"] as! String
                    currentDepartmentID = data["Department ID"] as! String
                   // print(currentDepartmentName)
                   // print(currentDepartmentID)
                    self.grabDepartmentEmployeeCount(currentDepartmentName: currentDepartmentName, currentDepartmentID: currentDepartmentID)
                }
                
            }
        }
        
    }
    //ran for each department
    func grabDepartmentEmployeeCount(currentDepartmentName: String, currentDepartmentID: String){
        var employees = [String]()
        self.database.collection("Departments").document("Department_\(currentDepartmentID)") .collection("Department Members").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err). There are no employees for this department.")
            } else {
                var departmentEmployeeCount = 0
                for document in querySnapshot!.documents {
                    let data = document.data()
                    var employeeID = data["Account ID"] as! String
                    employees.append(employeeID)
                    
                }
               // print(employees)
                if(employees.count > 0){
                    for name in 1 ... employees.count{
                        //increments the employee count when it iterates each document grabs from collection (should be each employee)
                        departmentEmployeeCount += 1
                    }
                }
                self.grabDepartmentActiveTicketCount(currentDepartmentName: currentDepartmentName, currentDepartmentID: currentDepartmentID, employeeCount: departmentEmployeeCount)
            }
        }
    }
    func grabDepartmentActiveTicketCount(currentDepartmentName: String, currentDepartmentID: String , employeeCount: Int){
        var activeTickets = [String]()
        self.database.collection("Departments").document("Department_\(currentDepartmentID)") .collection("Department Tickets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err). There are no active tickets for this department.")
            } else {
                var departmentActiveTicketCount = 0
                for document in querySnapshot!.documents {
                    let data = document.data()
                    //checks for tickets with status set to active
                    if(data["Status"] as! String == "Active"){
                        var currentActiveTicket = data["Department_Ticket_id"] as! String
                        activeTickets.append(currentActiveTicket)
                    }
                }
               // print(activeTickets)
                
                if(activeTickets.count > 0){
                    for ticket in 1 ... activeTickets.count{
                        //increments the employee count when it iterates each document grabs from collection (should be each employee)
                        departmentActiveTicketCount += 1
                    }
                }
                
                self.grabDepartmentCompletedTicketCount(currentDepartmentName: currentDepartmentName, currentDepartmentID: currentDepartmentID, employeeCount: employeeCount, activeTicketCount: departmentActiveTicketCount)
            }
        }
        
    }
    func grabDepartmentCompletedTicketCount(currentDepartmentName: String, currentDepartmentID: String , employeeCount: Int, activeTicketCount: Int){
        var completedTickets = [String]()
        self.database.collection("Departments").document("Department_\(currentDepartmentID)") .collection("Department Tickets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err). There are no completed tickets for this department.")
            } else {
                var departmentCompletedTicketCount = 0
                for document in querySnapshot!.documents {
                    let data = document.data()
                    //checks for tickets with status set to active
                    if(data["Status"] as! String == "Complete"){
                        var currentCompletedTicket = data["Department_Ticket_id"] as! String
                        completedTickets.append(currentCompletedTicket)
                    }
                }
                
                print(completedTickets)
                
                if(completedTickets.count > 0){
                    for ticket in 1 ...  completedTickets.count{
                        //increments the employee count when it iterates each document grabs from collection (should be each employee)
                        departmentCompletedTicketCount += 1
                    }
                }
                //print("Completed Ticket Count: \(departmentCompletedTicketCount)")
                self.fillDepartmentData(currentDepartmentName: currentDepartmentName, currentDepartmentID: currentDepartmentID, employeeCount: employeeCount, activeTicketCount: activeTicketCount, completedTicketCount: departmentCompletedTicketCount)
            }
        }
        
    }
    func fillDepartmentData(currentDepartmentName: String, currentDepartmentID: String , employeeCount: Int, activeTicketCount: Int, completedTicketCount: Int){
        
//        print("Department Name: \(currentDepartmentName)")
//        print("Department ID: \(currentDepartmentID)")
//        print("Department Employee Count: \(employeeCount)")
//        print("Active Ticket Count: \(activeTicketCount)")
//        print("Completed Ticket Count: \(completedTicketCount)")
//
        
        
        
        AdminViewExistingDepartments.existingDepartments.append(ExistingDepartmentDataForCell(departmentName: currentDepartmentName, departmentID: currentDepartmentID, departmentEmployeeCount: String(employeeCount), departmentActiveTicketCount: String(activeTicketCount), departmentCompletedTicketCount: String(completedTicketCount)))
        
    }
    
    
    
    
    
    //MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdminViewExistingDepartments.existingDepartments.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 150}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomExistingDepartmentTableViewCell
        cell.departmentNameLabel.text = AdminViewExistingDepartments.existingDepartments[indexPath.row].departmentName
        cell.departmentIDLabel.text = AdminViewExistingDepartments.existingDepartments[indexPath.row].departmentID
        cell.numberOfWorkingEmployeesCountLabel.text = AdminViewExistingDepartments.existingDepartments[indexPath.row].departmentEmployeeCount
        cell.numberOfActiveTicketsCountLabel.text = AdminViewExistingDepartments.existingDepartments[indexPath.row].departmentActiveTicketCount
        cell.numberOfCompletedTicketsCountLabel.text = AdminViewExistingDepartments.existingDepartments[indexPath.row].departmentCompletedTicketCount
        
        return cell
    }
}
struct ExistingDepartmentDataForCell{
    var departmentName: String
    var departmentID: String
    var departmentEmployeeCount: String
    var departmentActiveTicketCount: String
    var departmentCompletedTicketCount: String
}
class CustomExistingDepartmentTableViewCell: UITableViewCell {
    @IBOutlet weak var departmentNameLabel: UILabel!
    @IBOutlet weak var departmentIDLabel: UILabel!
    @IBOutlet weak var numberOfWorkingEmployeesCountLabel: UILabel!
    @IBOutlet weak var numberOfActiveTicketsCountLabel: UILabel!
    @IBOutlet weak var numberOfCompletedTicketsCountLabel: UILabel!
}
