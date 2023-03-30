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

class ConcertsViewController: UIViewController {
    
    var myArtists:[String] = []
    
    var sharedConcerts:[SharedConcert] = []
    
    let TICKETMASTER_API_KEY: String = "TICKETMASTER_DISCOVERY_API_KEY"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.writeDataIntoFirebase()
        // Get events in US: https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey={apikey}
        // TODO: Call endpoint with concert events
        // within user's location
        //        let fetchEventsEndpoint: String = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey=\(ProcessInfo.processInfo.environment[self.TICKETMASTER_API_KEY]!)&keyword=SZA"
        
        
//        self.fetchUserArtistData { completion in
//            if completion {
//
//                for artist in self.myArtists {
//                    let fetchEventsEndpoint: String = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey=\(ProcessInfo.processInfo.environment[self.TICKETMASTER_API_KEY]!)&keyword=\(artist)"
//                    //                    print(fetchEventsEndpoint)
//                    self.callAPI(endpoint: fetchEventsEndpoint, artist: artist) { completion in
//                        if completion {
//                            self.writeDataIntoFirebase()
//                            // PUT FIREBASE LOGIC IN HERE
//                            //                            self.printOutput()
//                        } else {
//                            print("error")
//                        }
//
//                    }
//
//
//                }
//
//
//            } else {
//                print("error")
//            }
 //       }
    }
    
    func writeDataIntoFirebase() {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        let document = ref.document(currentUser!)
        
        document.updateData(["Shared Concerts" : sharedConcerts])
     
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
                    let concertBuddies = sharedArtists[artist]?.friends
                    sharedConcert.friends = concertBuddies!
                    self!.sharedConcerts.append(sharedConcert)
                    
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

