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
    let images: [ImageData]
}

struct ImageData: Decodable {
    let ratio: String?
    let url: String
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
    let imageUrl: String?
    let date: String?
//    var visited: Bool
//    var going: Bool
}

class ConcertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var myArtists:[String] = []
    
    var sharedConcerts:[SharedConcert] = []
    var filteredSharedConcerts: [SharedConcert] = []
    
    let TICKETMASTER_API_KEY: String = "TICKETMASTER_DISCOVERY_API_KEY"
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let concertCellIdentifier = "ConcertCard"
    
    func getConcertDataFromTicketMaster() {
        for artist in sharedArtists {
            let fetchEventsEndpoint: String = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey=\(ProcessInfo.processInfo.environment[self.TICKETMASTER_API_KEY]!)&keyword=\(artist.key)"
            //                    print(fetchEventsEndpoint)
            let fetchEventsEncodedEndpoint: String = fetchEventsEndpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            self.callAPI(endpoint: fetchEventsEncodedEndpoint, artist: artist.value.getName()) { completion in
                if completion {
                    self.writeDataIntoFirebase()
                    print("IN COMPLETION \(self.sharedConcerts.count)")
                    DispatchQueue.main.async {
                        self.filteredSharedConcerts = self.sharedConcerts
                        self.tableView.reloadData()
                        if self.sharedConcerts.isEmpty {
                            self.tableView.isHidden = true
                            self.emptyLabel.isHidden = false
                        }
                    }
                } else {
                    print("error")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.writeDataIntoFirebase()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "ConcertCard", bundle: nil), forCellReuseIdentifier: concertCellIdentifier)
        emptyLabel.isHidden = true
        
        getConcertDataFromTicketMaster()
        
        print("Num of Shared Artists: \(sharedArtists.count)")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func fetchImages(_ concert: SharedConcert,_ cell: ConcertTableViewCell, _ completion: @escaping (_ success: Bool) -> Void)  {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageURL = URL(string: concert.concertImageURL ?? "https://imageio.forbes.com/specials-images/imageserve/746559733/960x0.jpg?format=jpg&width=960")!
            let imageData = NSData(contentsOf: imageURL)
            DispatchQueue.main.async {
                cell.artistImage.image = UIImage(data: imageData! as Data)
                cell.cardView.backgroundColor = cell.artistImage.image?.averageColor?.lighter(by: 0.4)
            }
        }
        completion(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSharedConcerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: concertCellIdentifier, for: indexPath) as! ConcertTableViewCell
        let concert = filteredSharedConcerts[indexPath.row]
        cell.artistName.text = concert.concertName
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let date = dateFormatterGet.date(from: concert.concertDate ?? "")
        
        cell.date.text = dateFormatterPrint.string(from: date!)
        cell.concertDescription.text = writeConcertDescription(concertFriends: concert.friends)
        fetchImages(concert, cell) { completion in
            if completion {
                print("images correctly fetched")
            } else {
                print("error")
            }
        }
        return cell
    }
    
    private func writeConcertDescription(concertFriends friends: [String]) -> String{
        var desc = "Your concert budd"
        switch friends.count {
        case 0:
            desc = "You are your own concert buddy!"
        case 1:
            desc += "y is \(friends[0])"
        case 2:
            desc += "ies are \(friends[0]) and \(friends[1])"
        case 3:
            desc += "ies are \(friends[0]), \(friends[1]), and \(friends[2])"
        default:
            desc += "ies are \(friends[0]), \(friends[1]), \(friends[2]), and more!"
        }
        return desc
    }
        
    func writeDataIntoFirebase() {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        let document = ref.document(currentUser!)
        // Store shared concerts in user's
        // shared concert
        var sharedConcertsArr = [[String:Any]]()
        print("writeDataIntoFirebase: \(sharedConcerts.count)")
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
        guard let url = URL(string: endpoint) else { print("Failed! \(endpoint)")
            return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { print("DATA NOT LOADING")
                return }
            if let newEvents = self?.parseEventsJSON(data: data) {
                print("IF NEW EVENTS")
                for event in newEvents {
                    let sharedConcert = SharedConcert()
                    sharedConcert.concertName = event.name
                    if event.date != nil {
                        sharedConcert.concertDate = event.date
                    }
                    if event.imageUrl != nil {
                        sharedConcert.concertImageURL = event.imageUrl
                    }
                    if sharedArtists[artist] != nil {
                        let concertBuddies = sharedArtists[artist]?.friends
                        sharedConcert.friends = concertBuddies!
                        self!.sharedConcerts.append(sharedConcert)
                    }
                    
                }
            }
            print ("shared concerts call api \(self!.sharedConcerts.count)")
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
                let imageUrl = getImageUrl(images: decodedData._embedded.events[i].images)
                let event = Event(name: name,  imageUrl: imageUrl, date: date)
                events.append(event)
                if i > 20 { break }
            }
        } catch {
            print(error)
        }
        return events
    }
    
    func getImageUrl(images: [ImageData]?) -> String? {
            if images == nil || images!.isEmpty { return nil }
            for image in images! {
                if image.ratio != "16_9" {
                    return image.url
                }
            }
            return images![0].url
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredSharedConcerts = sharedConcerts
        } else {
            filteredSharedConcerts = sharedConcerts.filter { (item: SharedConcert) -> Bool in
                let concert = item.concertName
                return concert.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        
        tableView.reloadData()
    }
}

