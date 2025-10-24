//
//  ContentView.swift
//  dummy
//
//  Created by Erlan Kanybekov on 9/23/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var dateTimeData: DateTimeDTO?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading...")
            } else if let data = dateTimeData {
                DateTimeView(dateTime: data)
            } else {
                Text("Failed to load data")
                    .foregroundColor(.red)
            }
        }
        .task {
            await loadData()
        }
    }
    
    @MainActor
    private func setResult(_ result: DateTimeDTO?) {
        self.dateTimeData = result
        self.isLoading = false
    }
    
    private func loadData() async {
        let loader = JSONLoader()
        let data = await loader.loadLocalJSON("mydata", as: DateTimeDTO.self)
        setResult(data) // no await needed; it's a synchronous @MainActor function
    }
}

struct DateTimeView: View {
    let dateTime: DateTimeDTO?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date & Time Info")
                .font(.title2)
                .bold()
            
            Group {
                HStack {
                    Text("Date:")
                    Spacer()
                    Text(dateTime?.date ?? "")
                }
                
                HStack {
                    Text("Time:")
                    Spacer()
                    Text(dateTime?.time ?? "")
                }
                
                HStack {
                    Text("Day of Week:")
                    Spacer()
                    Text(dateTime?.dayOfWeek ?? "")
                }
                
                HStack {
                    Text("Time Zone:")
                    Spacer()
                    Text(dateTime?.timeZone ?? "")
                }
                
                HStack {
                    Text("DST Active:")
                    Spacer()
                    Text(String(dateTime?.dstActive ?? false))
                        .foregroundColor(dateTime?.dstActive == true ? .green : .red)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    ContentView()
}
