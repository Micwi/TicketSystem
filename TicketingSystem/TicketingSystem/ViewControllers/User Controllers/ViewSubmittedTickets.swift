//
//  ViewSubmittedTickets.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 8/8/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ViewSubmittedTickets: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let database = Firestore.firestore()
    
    static var ticketsInCurrentWeek = [TicketInfoForCell]()
    static var ticketsBeforeCurrentWeek = [TicketInfoForCell]()
    
    @IBOutlet weak var submittedTicketsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabTicketData()
        submittedTicketsTableView.delegate = self
        submittedTicketsTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.submittedTicketsTableView.reloadData()
    }
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    
    func grabTicketData(){
        ViewSubmittedTickets.ticketsInCurrentWeek = [TicketInfoForCell]()
        ViewSubmittedTickets.ticketsBeforeCurrentWeek = [TicketInfoForCell]()
        let calendar = Calendar(identifier: .gregorian)
        let accountID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        self.database.collection("Accounts").document("\(accountID)").collection("Submitted_Tickets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    var ticketDateWeekNumberInMonth = " "
                    var currentWeekNumberInMonth = " "
                    let ticketDate = data["Submission Date"] as! String
                    print("Ticket Date: \(ticketDate)")
                    let splittedDate = ticketDate.split(separator: "/")
                    let year = splittedDate[2]
                    let month = splittedDate[0]
                    let day = splittedDate[1]
                    var inputYear = " "
                    if(Int(year) == 21){inputYear = "2021"}
                    else if (Int(year) == 22){inputYear = "2022"}
                    else if (Int(year) == 23){inputYear = "2023"}
                    var inputMonth = " "
                    let splitMonth = Array(month)
                    var tempMonthNumber = 0
                    //for the months that have a 0 in front -> 1-9
                    if(month.contains("0")){
                        for i in 1..<10{
                            //grabs the month number without the 0 to be put in when searching which document to update in database. Since each document is a month of the year
                            if(splitMonth[1].wholeNumberValue == i){ inputMonth = "0\(i)_\(inputYear)"
                                tempMonthNumber = splitMonth[1].wholeNumberValue!
                            }
                        }
                    }else{
                        if(Int(month) == 10){ inputMonth = "10_\(inputYear)"}
                        else if(Int(month) == 11){ inputMonth = "11_\(inputYear)"}
                        else if(Int(month) == 12){ inputMonth = "12_\(inputYear)"}
                    }
                    let date = calendar.date(from: DateComponents(calendar: calendar, era: 1, year: Int(inputYear), month: tempMonthNumber , day: Int(day)))
                    //grabs week of the month based on day
                    print("Here is the week of the month your order falls in:")
                    print(calendar.component(.weekOfMonth, from: date!))
                    ticketDateWeekNumberInMonth = String(calendar.component(.weekOfMonth, from: date!))
                    currentWeekNumberInMonth = String(calendar.component(.weekOfMonth, from: Date()))
                    if(ticketDateWeekNumberInMonth == currentWeekNumberInMonth){
                        print("Within current week!")
                        print("--------------")
                        ViewSubmittedTickets.ticketsInCurrentWeek.append(TicketInfoForCell(ticketID: (data["Ticket_id"] as! String), fullName: (data["Full Name"] as! String), submissionDate: (data["Submission Date"] as! String), submissionTime: (data["Submission Time"] as! String), department: (data["Department"] as! String), subject: (data["Subject"] as! String), description: (data["Description"] as! String), status: (data["Status"] as! String)))
                    }
                    else{
                        print("Ticket not within current week!")
                        print("--------------")
                        ViewSubmittedTickets.ticketsBeforeCurrentWeek.append(TicketInfoForCell(ticketID: (data["Ticket_id"] as! String), fullName: (data["Full Name"] as! String), submissionDate: (data["Submission Date"] as! String), submissionTime: (data["Submission Time"] as! String), department: (data["Department"] as! String), subject: (data["Subject"] as! String), description: (data["Description"] as! String), status: (data["Status"] as! String)))
                    }
                    
                }
                print("--------------")
                print("Tickets within current week: \(ViewSubmittedTickets.ticketsInCurrentWeek)")
                print("-----------------")
                print("Tickets before current week: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek)")
            }
    }
    }

    
    //Tableview methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 150}
    // Set the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = 2
        return numberOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){return ViewSubmittedTickets.ticketsInCurrentWeek.count}
        else if (section == 1){return ViewSubmittedTickets.ticketsBeforeCurrentWeek.count}
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            print("Ticket tapped with ID: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].ticketID)")
            ViewTicketInfo.fullName = ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].fullName
            ViewTicketInfo.subject = ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].subject
            ViewTicketInfo.description_ = ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].description
            ViewTicketInfo.ticketID = ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].ticketID
            ViewTicketInfo.department = ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].department
        } else if(indexPath.section == 1){
            print("Ticket tapped with ID: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].ticketID)")
            ViewTicketInfo.fullName = ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].fullName
            ViewTicketInfo.subject = ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].subject
            ViewTicketInfo.description_ = ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].description
            ViewTicketInfo.ticketID = ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].ticketID
            ViewTicketInfo.department = ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].department
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTicketInfoCell
        if(indexPath.section == 0){
            cell.ticketIDLabel.text = ("Ticket ID: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].ticketID)")
            cell.submissionDateLabel.text = ("Submitted On: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].submissionDate)")
            cell.submissionTimeLabel.text = ("Submitted At: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].submissionTime)")
            cell.departmentLabel.text = ("Department: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].department)")
            cell.fullNameLabel.text = ("Submitted By: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].fullName)")
            cell.statusLabel.text = ("Status: \(ViewSubmittedTickets.ticketsInCurrentWeek[indexPath.row].status)")
        }
        else if(indexPath.section == 1){
            cell.ticketIDLabel.text = ("Ticket ID: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].ticketID)")
            cell.submissionDateLabel.text = ("Submitted On: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].submissionDate)")
            cell.submissionTimeLabel.text = ("Submitted At: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].submissionTime)")
            cell.departmentLabel.text = ("Department: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].department)")
            cell.fullNameLabel.text = ("Submitted By: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].fullName)")
            cell.statusLabel.text = ("Status: \(ViewSubmittedTickets.ticketsBeforeCurrentWeek[indexPath.row].status)")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = String()
        if section == 0 { sectionTitle = "This Week" }
        else if section == 1 { sectionTitle = "Before This Week" }
        return sectionTitle
    }
   
    //FIGURE OUT HOW TO MAKE SECTION TITLE DARKER IN TABLE VIEW FOR SUBMITTED TICKETS WHEN RAN ON IPHONE
    
}
struct TicketInfoForCell{
    var ticketID: String
    var fullName: String
    var submissionDate: String
    var submissionTime: String
    var department: String
    var subject: String
    var description: String
    var status: String
}

class CustomTicketInfoCell: UITableViewCell{
    @IBOutlet weak var submissionDateLabel: UILabel!
    @IBOutlet weak var submissionTimeLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var ticketIDLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

