//
//  ViewTicketInfo.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 8/10/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ViewTicketInfo: UIViewController{
    
    private let database = Firestore.firestore()
    static var ticketID = " "
    static var fullName = " "
    static var subject = " "
    static var description_ = " "
    static var department = " "
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var ticketIDLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayDataFromTicket(ticketID: ViewTicketInfo.ticketID, fullName: ViewTicketInfo.fullName, subject: ViewTicketInfo.subject, description: ViewTicketInfo.description_, department: ViewTicketInfo.department)
    }
    func displayDataFromTicket(ticketID: String, fullName: String, subject: String, description: String, department: String){
        self.ticketIDLabel.text = ticketID
        self.fullNameLabel.text = fullName
        self.subjectTextField.text = subject
        self.descriptionTextView.text = description
        self.departmentLabel.text = department
        
    }
    
    
    
}
