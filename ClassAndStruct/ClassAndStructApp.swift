//
//  ClassAndStructApp.swift
//  ClassAndStruct
//
//  Created by Dojin Park on 2023/08/20.
//

import SwiftUI

@main
struct ClassAndStructApp: App {
    
    @State var tab: Int = 0
    
    var body: some Scene {
        WindowGroup {
            
            let classData: [ClassData] = buildRandomData(size: 10000)
            
            let structData: [StructData] = buildRandomData(size: 10000)
            
            let observedData: [ObservableData] = buildRandomData(size: 10000)
            
            TabView(selection: $tab) {
                
                NavigationStack {
                    Stack(data: classData)
                }
                .id(0)
                .tabItem {
                    Text("Class")
                }
                
                NavigationStack {
                    Stack(data: structData)
                }
                .id(1)
                .tabItem {
                    Text("Struct")
                }
                
                NavigationStack {
                    ObservedStack(data: observedData)
                }
                .id(2)
                .tabItem {
                    Text("Observed")
                }
            }
        }
    }
}

protocol DataProtocol {
    var id: UUID { get set }
    var title: String { get set }
    var bodyText: String { get set }
    var footnote: String { get set }
    var imageUrl: URL { get set }
    
    init()
}

extension DataProtocol {
    mutating func modifyData() {
        self.title = randomString()
        self.bodyText = randomString()
        self.footnote = randomString()
        self.imageUrl = randomImageUrl()
    }
}

final class ClassData: DataProtocol {
    var id: UUID = .init()
    var title: String = randomString()
    var bodyText: String = randomString()
    var footnote: String = randomString()
    var imageUrl: URL = randomImageUrl()
}

struct StructData: DataProtocol {
    var id: UUID = .init()
    var title: String = randomString()
    var bodyText: String = randomString()
    var footnote: String = randomString()
    var imageUrl: URL = randomImageUrl()
}

final class ObservableData: DataProtocol, ObservableObject {
    @Published var id: UUID = .init()
    @Published var title: String = randomString()
    @Published var bodyText: String = randomString()
    @Published var footnote: String = randomString()
    @Published var imageUrl: URL = randomImageUrl()
}

struct Stack<Element: DataProtocol>: View {
    
    @State var data: [Element]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(data, id: \.id) { element in
                    cell(element)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Reset Data") {
                    for (idx, _) in data.enumerated() {
                        data[idx] = .init()
                    }
                }
                
                Button("Modify Data") {
                    for (idx, _) in data.enumerated() {
                        data[idx].modifyData()
                    }
                }
                
                Button("Modify Title") {
                    for (idx, _) in data.enumerated() {
                        data[idx].title = randomString()
                    }
                }
            }
        }
    }
    
    @ViewBuilder func cell(_ element: any DataProtocol) -> some View {
        HStack {
            VStack {
                Text(element.title).font(.headline)
                Text(element.bodyText).font(.footnote)
                Text(element.footnote).font(.caption2)
            }
        }
    }
}

struct ObservedStack: View {
    
    @State var data: [ObservableData]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(data, id: \.id) { element in
                    Cell(element: element)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Reset Data") {
                    for (idx, _) in data.enumerated() {
                        data[idx] = .init()
                    }
                }
                
                Button("Modify Data") {
                    for (idx, _) in data.enumerated() {
                        data[idx].modifyData()
                    }
                }
                
                Button("Modify Title") {
                    for (idx, _) in data.enumerated() {
                        data[idx].title = randomString()
                    }
                }
            }
        }
    }
}

struct Cell: View {
    
    @ObservedObject var element: ObservableData
    
    var body: some View {
        HStack {
            VStack {
                Text(element.title).font(.headline)
                Text(element.bodyText).font(.footnote)
                Text(element.footnote).font(.caption2)
            }
        }
    }
}






func buildRandomData<Element: DataProtocol>(size: Int) -> [Element] {
    var ret = [Element]()
    for _ in 0..<size {
        ret.append(.init())
    }
    return ret
}

var letterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func randomString() -> String {
    var ret: String = ""
    for _ in 0..<Int.random(in: 1...10) {
        ret.append(letterSet.randomElement()!)
    }
    return ret
}

func randomImageUrl() -> URL {
    let index = Int.random(in: 0...1084)
    return URL(string: "https://picsum.photos/id/\(index)/1000/")!
}






