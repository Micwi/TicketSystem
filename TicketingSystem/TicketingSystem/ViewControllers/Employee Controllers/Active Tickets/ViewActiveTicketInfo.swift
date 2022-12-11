//
//  ViewActiveTicketInfo.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 11/27/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ViewActiveTicketInfo: UIViewController{
    
    private let database = Firestore.firestore()
    
    static var departmentTicketID = " "
    static var fullName = " "
    static var subject = " "
    static var submissionTime = " "
    static var submissionDate = " "
    static var isTicketComplete = false
    
    
    @IBAction func markAsCompleteButtonTapped(_ sender: Any) {
        ViewActiveTicketInfo.isTicketComplete = true
        updateTicketStatusInDepartmentDB(departmentTicketID: ViewActiveTicketInfo.departmentTicketID)
    }
    @IBOutlet weak var ticketNumberTitleLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var subjectTextField: UITextField!
    
    @IBOutlet weak var submissionDateLabel: UILabel!
    
    @IBOutlet weak var submissionTimeLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var submitterNameLabel: UILabel!
    @IBOutlet weak var ticketID_Label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        grabDepartmentName(departmentID: EmployeeDashboard.departmentID,departmentTicketID: ViewActiveTicketInfo.departmentTicketID)
    }
    func updateTicketStatusInDepartmentDB(departmentTicketID: String){
        let docRef = self.database.collection("Departments").document("Department_\(EmployeeDashboard.departmentID)").collection("Department Tickets").document("Ticket_Number_\(departmentTicketID)").setData([
            "Status": "Complete",
        ], merge: true) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!")
                self.navigationController?.popViewController(animated: true)
                self.grabSubmitterAccountID(ticketID: departmentTicketID)
            }
        }
        
        
    }
    func updateTicketStatusInDB(ticketID: String, accountID: String){
        let docRef = self.database.collection("Accounts").document("\(accountID)").collection("Submitted_Tickets").document("Submitted_Ticket_\(ticketID)").setData([
            "Status": "Complete",
        ], merge: true) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!")
                self.navigationController?.popViewController(animated: true)

            }
        }
    }
    
    func grabSubmitterAccountID(ticketID: String){
        let docRef = self.database.collection("Departments").document("Department_\(EmployeeDashboard.departmentID)").collection("Department Tickets").document("Ticket_Number_\(ViewActiveTicketInfo.departmentTicketID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                // self.rejectedAccountWarning()
                return
            }
            var accountID = " "
            accountID = data["Submitter's Account ID"] as! String
            self.updateTicketStatusInDB(ticketID: ticketID, accountID: accountID)
        }
    }
    func grabDepartmentName(departmentID: String, departmentTicketID: String){
        var departmentName = ""
        let docRef = self.database.collection("Departments").document("Department_\(departmentID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
               // self.rejectedAccountWarning()
                return
            }
            departmentName = data["Department Name"] as! String
            self.grabTicketDescription(departmentName: departmentName, departmentID: departmentID, ticketID: departmentTicketID)
        }
    }
    func grabTicketDescription(departmentName: String, departmentID: String, ticketID: String){
        var ticketDescription = " "
        let docRef = self.database.collection("Departments").document("Department_\(departmentID)").collection("Department Tickets").document("Ticket_Number_\(ticketID)")
            docRef.getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                   // self.rejectedAccountWarning()
                    return
                }
                ticketDescription = data["Description"] as! String
                self.labels(department: departmentName, ticketDescription: ticketDescription)
            }
        
    }
    func labels(department: String, ticketDescription: String){
        self.ticketNumberTitleLabel.text = "Ticket #\(ViewActiveTicketInfo.departmentTicketID)"
        self.ticketID_Label.text = ViewActiveTicketInfo.departmentTicketID
        self.submissionDateLabel.text = ViewActiveTicketInfo.submissionDate
        self.submissionTimeLabel.text = ViewActiveTicketInfo.submissionTime
        self.submitterNameLabel.text = ViewActiveTicketInfo.fullName
        self.subjectTextField.text = ViewActiveTicketInfo.subject
        self.descriptionTextView.text = ticketDescription
        self.departmentLabel.text = department
    }
}
