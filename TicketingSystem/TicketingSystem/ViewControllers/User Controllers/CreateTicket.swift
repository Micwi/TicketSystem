//
//  CreateTicket.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 12/26/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
class CreateTicket: UIViewController {
    private let database = Firestore.firestore()
    private let storage = Storage.storage()
    private var newTicket = NewTicketInfo()
    @IBOutlet weak var INS_CreaterFN_Label: UILabel!
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var descriptionOfIssueTF: UITextField!
    @IBOutlet weak var previewTextView: UITextView!
    @IBOutlet weak var departmentPopUpButton: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var previewUIScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        grabbingCurrentUserFullname()
        popUpButtonSetup()
        departmentPopUpButton.layer.cornerRadius = 10
        currentDateLabel.text = getCurrentDate()
        
    }
    
    func popUpButtonSetup(){
        let optionClosure = {(action: UIAction) in
            print(action.title)}
        //Sets the different types of departments in menu
        departmentPopUpButton.menu = UIMenu(children:[
            UIAction(title: "No Selection", state: .on, handler: optionClosure),
            UIAction(title: "Marketing", state: .on, handler: optionClosure),
            UIAction(title: "Finance", state: .on, handler: optionClosure),
            UIAction(title: "Operations Management", state: .on, handler: optionClosure),
            UIAction(title: "Human Resources", state: .on, handler: optionClosure),
            UIAction(title: "IT", state: .on, handler: optionClosure)])
        departmentPopUpButton.showsMenuAsPrimaryAction = true
        departmentPopUpButton.changesSelectionAsPrimaryAction = true
        
    }
    func grabbingCurrentUserFullname(){
        let accountID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = database.collection("Accounts").document("\(accountID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {return}
            let fullName = "\(data["First Name"] as! String) \(data["Last Name"] as! String)"
            self.INS_CreaterFN_Label.text = fullName
        }
    }
    func getCurrentTime() -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm:ss a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let currentTime = formatter.string(from: Date())
        return currentTime
    }
    @IBAction func previewDescButtonTapped(_ sender: Any) {
        self.previewUIScrollView.sizeToFit()
        self.previewTextView.text = self.descriptionOfIssueTF.text
        
    }
    @IBAction func submitTicketButtonTapped(_ sender: Any) {
        //Variable used to ensure all fields have been filled when user creates new ticket. Gets incremented when a field is filled.
        var validFields = 0
        //Checking if department wasn't selected by user
        if(departmentPopUpButton.currentTitle == "No Selection"){
            print("Department not chosen!")
            self.departmentNotChosen()}
        else{
            validFields+=1
            newTicket.department = departmentPopUpButton.currentTitle!
        }
        if(subjectTF.text!.count == 0 && descriptionOfIssueTF.text!.count == 0){
            self.textFieldsAreBlank()
        }
        //Checks if subject field is empty
        if(subjectTF.text!.count == 0){
            print("Subject field is empty!")
            self.subjectFieldBlank()}
        else{
            validFields+=1
            newTicket.subject = self.subjectTF.text!
        }
        //Checks if description field is empty
        if(descriptionOfIssueTF.text!.count == 0){
            print("Description field is empty!")
            self.descriptionFieldBlank()}
        else{
            validFields+=1
            newTicket.description = self.descriptionOfIssueTF.text!
        }
        if(validFields == 3){
            print("All fields filled!")
            getNextAvailableTicketID()
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 120, width:self.view.frame.size.width, height:self.view.frame.size.height)
            })
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y + 120, width:self.view.frame.size.width, height:self.view.frame.size.height)
            })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.view.endEditing(true) }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    func submitTicket(TicketID: Int){
        //Push entry to database HERE
        let accountID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        self.database.collection("Accounts").document("\(accountID)").collection("Submitted_Tickets").document("Submitted_Ticket_\(TicketID)").setData([
            "Submitter's Account ID": accountID,
            "Ticket_id": String(TicketID),
            "Status": "Active",
            "Submission Date": getCurrentDate(),
            "Submission Time": getCurrentTime(),
            "Full Name": self.INS_CreaterFN_Label.text!,
            "Department": newTicket.department,
            "Subject": newTicket.subject,
            "Description": newTicket.description]) { err in
                if let err = err { print("Error writing document: \(err)")
                } else {
                    // alert for successful submission
                    self.ticketSubmittedAlert()
                    //calls a method that takes in the department name and returns the correct ID to then be used in the database path. Method in class called Assist, located in the AssistClass file
                    var departmentID = Assist.fetchDepartmentID(departmentName: self.newTicket.department);
                    
                    self.sendNewTicketInfoToDepartmentDB(departmentID: departmentID, departmentTicketID: TicketID, submitterAccountID: accountID)
                }}
    }
    //method to push new ticket to the department database
    func sendNewTicketInfoToDepartmentDB(departmentID: String, departmentTicketID: Int, submitterAccountID: String){
        //database path
        self.database.collection("Departments").document("Department_\(departmentID)").collection("Department Tickets").document("Ticket_Number_\(departmentTicketID)").setData([
            "Submitter's Account ID": submitterAccountID,
            "Department_Ticket_id": String(departmentTicketID),
            "Status": "Active",
            "Submission Date": getCurrentDate(),
            "Submission Time": getCurrentTime(),
            "Full Name": self.INS_CreaterFN_Label.text!,
            "Department": newTicket.department,
            "Subject": newTicket.subject,
            "Description": newTicket.description]) { err in
                if let err = err { print("Error writing document: \(err)")
                } else {
                    //prints this in console to tell developer that the ticket was pushed to department database
                    print("Ticket Sent to the correct Department Database!")
                    //reseting the struct for a new ticket
                    self.newTicket = NewTicketInfo()
                }}
    }
    
    
   
    func getNextAvailableTicketID(){
        var ticketIDs = [Int]()
        let accountID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        self.database.collection("Accounts").document("\(accountID)").collection("Submitted_Tickets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var ticketID = 0
                var newID = Int.random(in: 1...99)
                for document in querySnapshot!.documents {
                    let tempTicketID = Int(document.data()["Ticket_id"] as! String)!
                    ticketIDs.append(tempTicketID)
                }
                print(ticketIDs)
                if(ticketIDs.isEmpty){
                    ticketID = newID
                }else{
                    for i in 1..<ticketIDs.count {
                        if(newID == i){
                            continue
                        }else{
                            ticketID = newID
                        }
                    }
                }
                ticketIDs = [Int]()
                self.submitTicket(TicketID: ticketID)
            }
        }
    }
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("The subject and description fields are blank. Please fill in the fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func departmentNotChosen(){
        let alertController = UIAlertController(title: NSLocalizedString("No department was chosen!",comment:""), message: NSLocalizedString("Please choose which department to send this ticket to. Thank you.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func subjectFieldBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("The subject field is empty!",comment:""), message: NSLocalizedString("Please fill in the subject field for this ticket. Thank you.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func descriptionFieldBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("The description field is empty!",comment:""), message: NSLocalizedString("Please fill in the description field for this ticket. Thank you.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func ticketSubmittedAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Ticket Submitted!",comment:""), message: NSLocalizedString("The ticket was successfully sent to the \(newTicket.department) department! Thank you.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
struct NewTicketInfo{
    var submissionDate = String()
    var submissionTime = String()
    var fullName = String()
    var department = String()
    var subject = String()
    var description = String()
}

