//
//  ConcertsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit

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
    let type: String
    let images: [ImageData]
    let dates: Dates
}

struct ImageData: Decodable {
    let ratio: String?
    let url: String
}

struct Dates: Decodable {
    let start: Start
}

struct Start: Decodable {
    let localDate: String
    let localTime: String
}

struct Event {
    let name: String
    let type: String
    let imageUrl: String?
    let date: Date?
    var visited: Bool
    var going: Bool
}

class ConcertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let TICKETMASTER_API_KEY: String = "TICKETMASTER_DISCOVERY_API_KEY"
    @IBOutlet weak var tableView: UITableView!
    let concertCellIdentifier = "ConcertCard"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "ConcertCard", bundle: nil), forCellReuseIdentifier: concertCellIdentifier)
        
        // Get events in US: https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey={apikey}
        // TODO: Call endpoint with concert events
        // within user's location
        let fetchEventsEndpoint: String = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey=\(ProcessInfo.processInfo.environment[self.TICKETMASTER_API_KEY]!)"
        callAPI(endpoint: fetchEventsEndpoint)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        //return concerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: concertCellIdentifier, for: indexPath) as! ConcertTableViewCell
        
        let row = indexPath.row
        
        cell.artistName.text = "Lil Nas X"
        cell.location.text = "Austin, Texas"
        cell.concertDescription.text = "Your concert buddies are Saahithi and Liz"
        
        return cell
    }
        
    func callAPI(endpoint: String) {
        guard let url = URL(string: endpoint) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            if let newEvents = self?.parseEventsJSON(data: data) {
                print(newEvents)
            }
        }
        task.resume()
    }
        
    func parseEventsJSON(data: Data) -> [Event] {
        var events = [Event]()
        do {
            let decodedData = try JSONDecoder().decode(EventData.self, from: data)
            for i in 0..<decodedData._embedded.events.count {
                let name = decodedData._embedded.events[i].name
                let type = decodedData._embedded.events[i].type
                let imageUrl = getImageUrl(images: decodedData._embedded.events[i].images)
                let date = getDate(day: decodedData._embedded.events[i].dates.start.localDate, time: decodedData._embedded.events[i].dates.start.localTime)
                let event = Event(name: name, type: type, imageUrl: imageUrl, date: date, visited: false, going: false)
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
    
    func getDate(day: String?, time: String?) -> Date? {
        if day == nil || time == nil { return nil }
        let dateStr = day! + time!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddHH-mm-ss"
        return dateFormatter.date(from: dateStr)
    }
}
