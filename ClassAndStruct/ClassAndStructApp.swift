//
//  ClassAndStructApp.swift
//  ClassAndStruct
//
//  Created by Dojin Park on 2023/08/20.
//

// 주장1 "Struct 는 스택 메모리를 사용, Class 는 힙 메모리를 사용. 힙 메모리는 메모리 관리 오버헤드가 있다."
// https://medium.com/macoclock/swift-struct-vs-class-performance-29b7be73d9fd

// 주장2 "실험해보니 Struct copy 가 Class copy 보다 훨씬 빠르다"
// https://stackoverflow.com/a/24243626

import SwiftUI
import UIKit

let DataSize = 10000

@main
struct ClassAndStructApp: App {
    
    @State var tab: Int = 0
    
    var body: some Scene {
        WindowGroup {
            
            let classData: [ClassData] = buildRandomData(size: DataSize)
            
            let structData: [StructData] = buildRandomData(size: DataSize)
            
            let observedData: [ObservableData] = buildRandomData(size: DataSize)
            
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
                
                TableRepresentation(data: structData)
                    .id(3)
                    .tabItem {
                        Text("Struct UIKit")
                    }
                
                TableRepresentation(data: classData)
                    .id(4)
                    .tabItem {
                        Text("Class UIKit")
                    }
                
            }
        }
    }
}

// MARK: Data Types
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

// MARK: 1. Class & 2. Struct
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



// MARK: 3. Observed
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
        VStack {
            Text(element.title).font(.headline)
            Text(element.bodyText).font(.footnote)
            Text(element.footnote).font(.caption2)
        }
    }
}


// MARK: 4. Class on UITableView & 5. Struct on UITableView
struct TableRepresentation: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UINavigationController
    
    var data: [any DataProtocol]
    
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: TableVC(data: data))
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}

class TableVC: UITableViewController {
    
    var data: [any DataProtocol]
    
    init(data: [any DataProtocol]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        let button1 = UIBarButtonItem(title: "Modify Data", primaryAction: UIAction{_ in
            for (idx, _) in data.enumerated() {
                self.data[idx].modifyData()
            }
            self.tableView.reloadData()
        })
        let button2 = UIBarButtonItem(title: "Modify Title", primaryAction: UIAction{_ in
            for (idx, _) in data.enumerated() {
                self.data[idx].title = randomString()
            }
            self.tableView.reloadData()
        })
        self.navigationItem.rightBarButtonItems = [
            button2,
            button1,
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.tableView.register(CellView.self, forCellReuseIdentifier: "CellView")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellView") as! CellView
        let element = data[indexPath.row]
        cell.configure(withData: element)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}


class CellView: UITableViewCell {
    func configure(withData data: any DataProtocol) {
        self.textLabel!.text = data.title
        
        let body = UILabel()
        body.font = .preferredFont(forTextStyle: .callout)
        body.text = data.bodyText
        
        let footnote = UILabel()
        footnote.font = .preferredFont(forTextStyle: .caption2)
        footnote.text = data.footnote
        
        let stack = UIStackView(arrangedSubviews: [
            body,
            footnote
        ])
        stack.axis = .vertical
        stack.frame = .init(origin: .zero, size: .init(width: 100, height: 70))
        
        self.accessoryView = stack
        
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






