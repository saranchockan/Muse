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

class ConcertsViewController: UIViewController {
    
    let TICKETMASTER_API_KEY: String = "TICKETMASTER_DISCOVERY_API_KEY"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get events in US: https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey={apikey}
        // TODO: Call endpoint with concert events
        // within user's location
        let fetchEventsEndpoint: String = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&apikey=\(ProcessInfo.processInfo.environment[self.TICKETMASTER_API_KEY]!)"
        callAPI(endpoint: fetchEventsEndpoint)
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
