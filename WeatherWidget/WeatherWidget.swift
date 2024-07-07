//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by sametbalci on 7.07.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cityName: "Istanbul", weather: "Loading...", weatherDescription: "Clear")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), cityName: "Istanbul", weather: "Sunny", weatherDescription: "Clear")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.yourapp.weather")
        let cityName = defaults?.string(forKey: "cityName") ?? "San Francisco"
        
        fetchWeather(for: cityName) { cityName, weather, weatherDescription in
            var entries: [SimpleEntry] = []
            let currentDate = Date()
            for hourOffset in 0..<5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, cityName: cityName, weather: weather, weatherDescription: weatherDescription)
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

    // Hava durumu bilgisini almak için OpenWeatherMap API'sine istek gönderme
    func fetchWeather(for cityName: String, completion: @escaping (String, String, String) -> Void) {
        let apiKey = "YOUR_API_KEY"
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let weatherResponse = try? decoder.decode(WeatherResponse.self, from: data) {
                    DispatchQueue.main.async {
                        completion(cityName, weatherResponse.weather.first?.main ?? "Unknown", weatherResponse.weather.first?.description ?? "Unknown")
                    }
                } else {
                    completion(cityName, "Failed to decode", "Unknown")
                }
            } else {
                completion(cityName, "Failed to fetch", "Unknown")
            }
        }.resume()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let weather: String
    let weatherDescription: String
}

struct WeatherResponse: Codable {
    struct Weather: Codable {
        let main: String
        let description: String
    }
    let weather: [Weather]
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.cityName)
                .font(.headline)
            Text(entry.date, style: .time)
                .font(.system(size: 24))
            Text(entry.weatherEmoji)
                .font(.system(size: 50))
            Text(entry.weatherDescription)
                .font(.system(size: 20))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .widgetURL(URL(string: "myapp://weather"))
    }
}

extension SimpleEntry {
    var weatherEmoji: String {
        switch weather {
        case "Clear":
            return "☀️"
        case "Clouds":
            return "☁️"
        case "Rain":
            return "🌧"
        case "Snow":
            return "❄️"
        case "Thunderstorm":
            return "⛈"
        case "Drizzle":
            return "🌦"
        default:
            return "❓"
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "MyWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather Widget")
        .description("Displays the current weather.")
    }
}

