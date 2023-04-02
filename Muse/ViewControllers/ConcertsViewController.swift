//
//  ConcertsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift



// Ticketmaster API call and event parsing
// code referenced from https://github.com/nastechi/MyEvents
struct EventData: Decodable {
    let _embedded: Embedded
}

struct Embedded: Decodable {
    let events: [EventItem]
}

struct EventItem: Decodable {
    let name: String
    let dates: Dates
}

struct Dates: Decodable {
    let start: Start
}

struct Start: Decodable {
    let localDate: String?
    let localTime: String?
}

struct Event {
    let name: String
//    let type: String
//    let imageUrl: String?
    let date: String?
//    var visited: Bool
//    var going: Bool
}

class ConcertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var myArtists:[String] = []
    
    var sharedConcerts:[SharedConcert] = []
    
    let TICKETMASTER_API_KEY: String = "TICKETMASTER_DISCOVERY_API_KEY"
    @IBOutlet weak var tableView: UITableView!
    let concertCellIdentifier = "ConcertCard"
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchUserArtistData { completion in
            if completion {

                for artist in self.myArtists {
                    let fetchEventsEndpoint: String = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey=\(ProcessInfo.processInfo.environment[self.TICKETMASTER_API_KEY]!)&keyword=\(artist)"
                    //                    print(fetchEventsEndpoint)
                    self.callAPI(endpoint: fetchEventsEndpoint, artist: artist) { completion in
                        if completion {
                            self.writeDataIntoFirebase()
                            // PUT FIREBASE LOGIC IN HERE
                            //                            self.printOutput()
                        } else {
                            print("error")
                        }

                    }


                }


            } else {
                print("error")
            }
       }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.writeDataIntoFirebase()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "ConcertCard", bundle: nil), forCellReuseIdentifier: concertCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        //return concerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: concertCellIdentifier, for: indexPath) as! ConcertTableViewCell
        _ = indexPath.row
        cell.artistName.text = "Lil Nas X"
        cell.location.text = "Austin, Texas"
        cell.concertDescription.text = "Your concert buddies are Saahithi and Liz"
        return cell
    }
        
    func writeDataIntoFirebase() {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        let document = ref.document(currentUser!)
        // Store shared concerts in user's
        // shared concert
        var sharedConcertsArr = [[String:Any]]()
        for sharedConcert in sharedConcerts {
            var concert = ["Concert Name": sharedConcert.concertName, "Concert Date": sharedConcert.concertDate!, "Concert Friends": sharedConcert.friends] as [String : Any]
            sharedConcertsArr.append(concert)
            
        }
        document.updateData(["Shared Concerts" : sharedConcertsArr])
    }
    
    func printOutput() {
        for sharedConcert in self.sharedConcerts{
            print("\(sharedConcert.concertName)")
            print("\(sharedConcert.concertDate ?? "")")
            for friend in sharedConcert.friends {
                print(friend)
            }
        }
    }
    
    func fetchUserArtistData(_ completion: @escaping (_ success: Bool) -> Void)  {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if document.documentID == currentUser {
                        let data = document.data()
                        self.myArtists = data["Top Artists"] as! [String]
                    }
                }
            }
            
            completion(true)
        }
    }
    
    
    
    func callAPI(endpoint: String, artist:String, _ completion: @escaping (_ success: Bool) -> Void) {
        guard let url = URL(string: endpoint) else {return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            if let newEvents = self?.parseEventsJSON(data: data) {
                for event in newEvents {
                    let sharedConcert = SharedConcert()
                    sharedConcert.concertName = event.name
                    if event.date != nil {
                        sharedConcert.concertDate = event.date
                    }
                    if sharedArtists[artist] != nil {
                        let concertBuddies = sharedArtists[artist]?.friends
                        sharedConcert.friends = concertBuddies!
                        self!.sharedConcerts.append(sharedConcert)
                    }
                    
                }
            }
            completion(true)
        }
        task.resume()
    }
    
    func parseEventsJSON(data: Data) -> [Event] {
        var events = [Event]()
        do {
            let decodedData = try JSONDecoder().decode(EventData.self, from: data)
            for i in 0..<decodedData._embedded.events.count {
                let name = decodedData._embedded.events[i].name
                let date = decodedData._embedded.events[i].dates.start.localDate
                let event = Event(name: name, date: date)
                events.append(event)
                if i > 20 { break }
            }
        } catch {
            print(error)
        }
        return events
    }
}

