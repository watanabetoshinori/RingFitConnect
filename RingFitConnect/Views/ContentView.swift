//
//  ContentView.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import HealthKit

struct ContentView: View {

    @ObservedObject var viewModel = ContentViewModel()

    @State private var isPresentingDocumentCamera = false

    var addDataButton: some View {
        Button("Add Data") {
            self.isPresentingDocumentCamera = true
        }
    }

    var noDataView: some View {
        GeometryReader { proxy in
            Text("No Data")
                .font(.title)
                .foregroundColor(.secondary)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .offset(x: 0, y: -40)
                .opacity(self.viewModel.workouts.isEmpty ? 1 : 0)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(self.viewModel.workouts, id: \.self) { workout in
                    WorkoutCell(day: workout.day,
                                weekday: workout.weekday,
                                duration: workout.formattedDuration,
                                calorie: workout.formattedCalorie,
                                distance: workout.formattedDistance)
                        .listRowInsets(EdgeInsets.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                }.onDelete(perform: self.viewModel.removeWorkouts)
            }
            .overlay(noDataView)
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(Text("Ring Fit Adenture"))
            .navigationBarItems(trailing: addDataButton)
            .onAppear(perform: viewModel.initialize)
            .alert(isPresented: viewModel.isPresentingAlert, content: alert)
            .sheet(isPresented: $isPresentingDocumentCamera) {
                DocumentCameraView(handler: { images in
                    self.viewModel.scan(images)
                })
                .edgesIgnoringSafeArea(.all)
            }
        }
    }

    private func alert() -> Alert {
        Alert(title: Text(viewModel.error?.localizedDescription ?? ""),
              message: nil,
              dismissButton: .default(Text("OK")))
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
