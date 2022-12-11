//
//  ViewCompletedTicketInfo.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 11/29/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ViewCompletedTicketInfo: UIViewController {
    
    private let database = Firestore.firestore()
    
    static var departmentTicketID = " "
    static var fullName = " "
    static var subject = " "
    static var submissionTime = " "
    static var submissionDate = " "
    
    @IBOutlet weak var ticketNumberTopLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var submissionTimeLabel: UILabel!
    @IBOutlet weak var submissionDateLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var ticketIDLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        grabDepartmentName(departmentID: EmployeeDashboard.departmentID,departmentTicketID: ViewCompletedTicketInfo.departmentTicketID)
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
                self.setLabels(department: departmentName, ticketDescription: ticketDescription)
            }
        
    }
    func setLabels(department: String, ticketDescription: String){
        self.ticketNumberTopLabel.text = "Ticket #\(ViewCompletedTicketInfo.departmentTicketID)"
        self.ticketIDLabel.text = ViewCompletedTicketInfo.departmentTicketID
        self.submissionDateLabel.text = ViewCompletedTicketInfo.submissionDate
        self.submissionTimeLabel.text = ViewCompletedTicketInfo.submissionTime
        self.fullNameLabel.text = ViewCompletedTicketInfo.fullName
        self.subjectTextField.text = ViewCompletedTicketInfo.subject
        self.descriptionTextView.text = ticketDescription
        self.departmentLabel.text = department
    }
    
}
