//
//  ViewCompletedTickets.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 11/29/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class ViewCompletedTickets: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var viewEmployeeCompletedTicketsTableView: UITableView!
    private let database = Firestore.firestore()
    
    static var CompletedTickets = [CompletedTicketInfoForCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabTicketInfo()
        viewEmployeeCompletedTicketsTableView.delegate = self
        viewEmployeeCompletedTicketsTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.viewEmployeeCompletedTicketsTableView.reloadData()
    }
    
    
    func grabTicketInfo(){
        ViewCompletedTickets.CompletedTickets = [CompletedTicketInfoForCell]()
        
        self.database.collection("Departments").document("Department_\(EmployeeDashboard.departmentID)").collection("Department Tickets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {

                for document in querySnapshot!.documents {
                    let data = document.data()
                    if(data["Status"] as! String == "Complete"){
                        ViewCompletedTickets.CompletedTickets.append(CompletedTicketInfoForCell(ticketID: (data["Department_Ticket_id"] as! String), submitterName: (data["Full Name"] as! String), submissionDate: (data["Submission Date"] as! String), submissionTime: (data["Submission Time"] as! String), ticketSubject: (data["Subject"] as! String)))
                    }else{
                        print("Ticket Found is marked as Active")
                    }


                }
            }
        }
    }
    
    //MARK: Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewCompletedTickets.CompletedTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomEmployeeViewCompletedTicketCell
        cell.ticketID_Label.text = ("Ticket ID: \(ViewCompletedTickets.CompletedTickets[indexPath.row].ticketID)")
        cell.submittedDate_Label.text = ("Submitted On: \(ViewCompletedTickets.CompletedTickets[indexPath.row].submissionDate)")
        cell.submissionTimeLabel.text = ("Submitted At: \(ViewCompletedTickets.CompletedTickets[indexPath.row].submissionTime)")
        cell.submitterNameLabel.text = ("Submitted By: \(ViewCompletedTickets.CompletedTickets[indexPath.row].submitterName)")
        cell.subjectLabel.text = ("Subject: \(ViewCompletedTickets.CompletedTickets[indexPath.row].ticketSubject)")
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 150}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ViewCompletedTicketInfo.fullName = "\(ViewCompletedTickets.CompletedTickets[indexPath.row].submitterName)"
        ViewCompletedTicketInfo.submissionDate = "\(ViewCompletedTickets.CompletedTickets[indexPath.row].submissionDate)"
        ViewCompletedTicketInfo.submissionTime = "\(ViewCompletedTickets.CompletedTickets[indexPath.row].submissionTime)"
        ViewCompletedTicketInfo.departmentTicketID = "\(ViewCompletedTickets.CompletedTickets[indexPath.row].ticketID)"
        ViewCompletedTicketInfo.subject = "\(ViewCompletedTickets.CompletedTickets[indexPath.row].ticketSubject)"
        
    }
    
    
    
}
struct CompletedTicketInfoForCell{
    var ticketID: String
    var submitterName: String
    var submissionDate: String
    var submissionTime: String
    var ticketSubject: String
}
class CustomEmployeeViewCompletedTicketCell: UITableViewCell{
    
    @IBOutlet weak var ticketID_Label: UILabel!
    @IBOutlet weak var submissionTimeLabel: UILabel!
    @IBOutlet weak var submittedDate_Label: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var submitterNameLabel: UILabel!
    
}
