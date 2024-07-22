//
//  ContentView.swift
//  BetterRest
//
//  Created by Grace couch on 22/07/2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var coffeeIntake = 1
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingMessage = false

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("When would you like to wake up?") {
                    VStack(alignment: .center) {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                Section("Desired amount of sleep") {
                        Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeIntake) cup](inflect: true)", selection: $coffeeIntake) {
                        ForEach(0..<21) {
                            Text($0, format: .number)
                        }
                    }
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
        }
        .alert(alertTitle, isPresented: $showingMessage) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
}

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeIntake))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "There was a problem calculating your sleep time!"
        }
        showingMessage = true
    }
}

#Preview {
    ContentView()
}
