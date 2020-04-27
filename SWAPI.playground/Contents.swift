import Foundation

// MARK: - Models

struct Person: Decodable {
    let name: String
    let films: [URL]
}

struct Film: Decodable {
    let title: String
    let opening_crawl: String
    let release_date: String
}

// MARK: - Get data from api

class SwapiService {
    // The magic strings
    static private let baseURL = URL(string: "https://swapi.dev/api")
    static private let personEndPoint = "people"
    
    // Get a person object
    static func fetchPerson(id: Int, completion: @escaping (Person?) -> Void) {
        guard let baseURL = baseURL else { return completion(nil) }
        
        // 1 - Construct the url to get the relevant person from the api
        let personURL = baseURL.appendingPathComponent(personEndPoint)
        let finalURL = personURL.appendingPathComponent(String(id))
        
        // 2 - Get the data from the server
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            // 3 - If there was an error, print it out and return from the function
            if let error = error {
                print(error.localizedDescription)
                return completion(nil)
            }
            
            // 4 - Get the data if it worked correctly
            guard let data = data else { return completion(nil) }
            
            // 5 - Try to decode the data into the Person struct
            do {
                let person = try JSONDecoder().decode(Person.self, from: data)
                return completion(person)
            } catch {
                print(error.localizedDescription)
                return completion(nil)
            }
        }.resume()
    }
    
    // Get a film object
    static func fetchFilm(url: URL, completion: @escaping (Film?) -> Void) {
        // 1 - Get the data from the server
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            // 2 - If there was an error, print it out and return from the function
            if let error = error {
                print(error.localizedDescription)
                return completion(nil)
            }
            
            // 3 - Get the data if it worked correctly
            guard let data = data else { return completion(nil) }
            
            // 4 - Try to decode the data into the Person struct
            do {
                let film = try JSONDecoder().decode(Film.self, from: data)
                return completion(film)
            } catch {
                print(error.localizedDescription)
                return completion(nil)
            }
            
        }.resume()
    }
}

// MARK: - Test it out

func fetchFilm(url: URL) {
    SwapiService.fetchFilm(url: url) { film in
        if let film = film {
            print(film)
        }
    }
}

SwapiService.fetchPerson(id: 8) { person in
    if let person = person {
        print(person)
        for filmURL in person.films {
            fetchFilm(url: filmURL)
        }
    }
}
