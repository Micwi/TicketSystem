//
//  ViewActiveTickets.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 11/27/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore


class ViewActiveTickets: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var employeeActiveTicketTableView: UITableView!
    
    static var activeTickets = [ActiveTicketInfoForCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabTicketInfo()
        employeeActiveTicketTableView.delegate = self
        employeeActiveTicketTableView.dataSource = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.employeeActiveTicketTableView.reloadData()
    }
    func grabTicketInfo(){
        ViewActiveTickets.activeTickets = [ActiveTicketInfoForCell]()
        
        self.database.collection("Departments").document("Department_\(EmployeeDashboard.departmentID)").collection("Department Tickets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {

                for document in querySnapshot!.documents {
                    let data = document.data()
                    if(data["Status"] as! String == "Active"){
                        ViewActiveTickets.activeTickets.append(ActiveTicketInfoForCell(ticketID: (data["Department_Ticket_id"] as! String), submitterName: (data["Full Name"] as! String), submissionDate: (data["Submission Date"] as! String), submissionTime: (data["Submission Time"] as! String), ticketSubject: (data["Subject"] as! String)))
                    }else{
                        print("Ticket Found is marked as Complete")
                    }


                }
            }
        }
    }
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    
    
    //MARK: Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewActiveTickets.activeTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomEmployeeViewActiveTicketCell
        cell.ticketIDLabel.text = ("Ticket ID: \(ViewActiveTickets.activeTickets[indexPath.row].ticketID)")
        cell.submissionDateLabel.text = ("Submitted On: \(ViewActiveTickets.activeTickets[indexPath.row].submissionDate)")
        cell.submissionTimeLabel.text = ("Submitted At: \(ViewActiveTickets.activeTickets[indexPath.row].submissionTime)")
        cell.submitterFullNameLabel.text = ("Submitted By: \(ViewActiveTickets.activeTickets[indexPath.row].submitterName)")
        cell.ticketSubjectLabel.text = ("Subject: \(ViewActiveTickets.activeTickets[indexPath.row].ticketSubject)")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 150}
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ViewActiveTicketInfo.fullName = "\(ViewActiveTickets.activeTickets[indexPath.row].submitterName)"
        ViewActiveTicketInfo.submissionDate = "\(ViewActiveTickets.activeTickets[indexPath.row].submissionDate)"
        ViewActiveTicketInfo.submissionTime = "\(ViewActiveTickets.activeTickets[indexPath.row].submissionTime)"
        ViewActiveTicketInfo.departmentTicketID = "\(ViewActiveTickets.activeTickets[indexPath.row].ticketID)"
        ViewActiveTicketInfo.subject = "\(ViewActiveTickets.activeTickets[indexPath.row].ticketSubject)"
        
    }
    
}

struct ActiveTicketInfoForCell{
    var ticketID: String
    var submitterName: String
    var submissionDate: String
    var submissionTime: String
    var ticketSubject: String
}
class CustomEmployeeViewActiveTicketCell: UITableViewCell{
    
    @IBOutlet weak var ticketIDLabel: UILabel!
    @IBOutlet weak var submitterFullNameLabel: UILabel!
    @IBOutlet weak var ticketSubjectLabel: UILabel!
    @IBOutlet weak var submissionDateLabel: UILabel!
    @IBOutlet weak var submissionTimeLabel: UILabel!
    
    
}
