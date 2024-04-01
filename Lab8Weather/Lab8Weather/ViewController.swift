//
//  ViewController.swift
//  Lab8Weather
//
//  Created by user240208 on 3/27/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate  {

    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windSpeed: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    func getDataFromAPI(lat: Double, lon: Double, completion: @escaping (Result<Weather, Error>) -> ()) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=d12cf7d594efca14ca2553dd7af64374&units=metric") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { jsonData, _, error in
            guard let jsonData = jsonData else { return }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: jsonData)
                completion(.success(weather))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func updateUI(data: Weather) {
        cityName.text = data.name ?? ""
        weatherDescription.text = data.weather?.first?.description ?? ""
        if let weatherurl = URL(string: "https://openweathermap.org/img/wn/\(data.weather?.first?.icon ?? "")@2x.png") {
            weatherIcon.load(url: weatherurl)
        }
        humidity.text = "Humidity: \(data.main?.humidity ?? 0)"
        windSpeed.text = "Wind: \(data.wind?.speed ?? 0)Km/h"
        temperature.text = "\(Int(data.main?.temp ?? 0))°C"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization weatherstatus: CLAuthorizationStatus) {
        if weatherstatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let weatherlocation = locations.first {
            getDataFromAPI(lat: weatherlocation.coordinate.latitude, lon: weatherlocation.coordinate.longitude) { [weak self] result in
                switch result {
                case .success(let success):
                    DispatchQueue.main.async {
                        self?.updateUI(data: success)
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    
}
extension UIImageView {
 func load(url: URL) {
     DispatchQueue.global().async { [weak self] in
         if let data = try? Data(contentsOf: url) {
             if let image = UIImage(data: data) {
                 DispatchQueue.main.async {
                     self?.image = image
                 }
             }
         }
     }
 }
}







