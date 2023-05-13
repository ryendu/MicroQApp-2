//
//  ContentView.swift
//  app
//
//  Created by Sergey Romanenko on 26.10.2020.
//

import SwiftUI

struct ContentView: View {
    var bluetooth = Bluetooth.shared
    @State var presented: Bool = false
    @State var list = [Bluetooth.Device]()
    @State var isConnected: Bool = Bluetooth.shared.current != nil { didSet { if isConnected { presented.toggle() } } }
    
    @State var response = Data()
    @State var rssi: Int = 0
    @State var string: String = ""
    @State var value: Float = 0
    @State var state: Bool = false { didSet { bluetooth.send([UInt8(state.int)]) } }
    
    @State var editing = false
    
    @State var lastUpdated: String? = nil
    
    var body: some View {
        NavigationView {
            VStack{
                if !isConnected {
                    HStack {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.red)
                            .padding(.trailing, 2)
                            .padding(.leading)
                        Text("Not connected")
                        
                        Spacer()
                        
                        Button("Scan"){ presented.toggle() }.buttonStyle(appButton()).padding()
                    }
                } else {
                    HStack {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.green)
                            .padding(.trailing, 2)
                            .padding(.leading)
                        
                        Text("Connected")
                        
                        Spacer()
                        
                        Button("Disconnect"){ bluetooth.disconnect() }.buttonStyle(appButton()).padding()
                    }
                }
                
                if isConnected {
//                    Slider(value: Binding( get: { value }, set: {(newValue) in sendValue(newValue) } ), in: 0...100).padding(.horizontal)
//                    Button("toggle"){ state.toggle() }.buttonStyle(appButton())
//                    TextField("string", text: $string, onEditingChanged: { editing = $0 })
//                        .onChange(of: string){ bluetooth.send(Array($0.utf8)) }
//                        .textFieldStyle(appTextField(focused: $editing))
//                    Text("returned byte value from \(bluetooth.current?.name ?? ""): \(response.hex)")
                    
                    Text("Value")
                        .font(.title2)
                    //swift convert string to double
                    
                    
                    
                    Text(String(format: "%.2f", Double(String(data: response, encoding: .utf8) ?? "nil") ?? "nil"))
                        .font(.largeTitle)
                    
                    if let lastUpdated = self.lastUpdated {
                        Text("Value last updated " + lastUpdated)
                            .fontWeight(.light)
                            .padding()
                    }
//                    Text("rssi: \(rssi)")
                }
                Spacer()
            }.sheet(isPresented: $presented){ ScanView(bluetooth: bluetooth, presented: $presented, list: $list, isConnected: $isConnected) }
                .onAppear{ bluetooth.delegate = self }
                .navigationTitle(Text("MicroQ"))
        }
    }
    
    func sendValue(_ value: Float) {
        if Int(value) != Int(self.value) {
            guard let sendValue = map(Int(value), of: 0...100, to: 0...255) else { return }
            bluetooth.send([UInt8(state.int), UInt8(sendValue)])
        }
        self.value = value
    }
    
    func map(_ value: Int, of: ClosedRange<Int>, to: ClosedRange<Int>) -> Int? {
        guard let ofmin = of.min(), let ofmax = of.max(), let tomin = to.min(), let tomax = to.max() else { return nil }
        return Int(tomin + (tomax - tomin) * (value - ofmin) / (ofmax - ofmin))
    }
}

extension ContentView: BluetoothProtocol {
    func state(state: Bluetooth.State) {
        switch state {
        case .unknown: print("◦ .unknown")
        case .resetting: print("◦ .resetting")
        case .unsupported: print("◦ .unsupported")
        case .unauthorized: print("◦ bluetooth disabled, enable it in settings")
        case .poweredOff: print("◦ turn on bluetooth")
        case .poweredOn: print("◦ everything is ok")
        case .error: print("• error")
        case .connected:
            print("◦ connected to \(bluetooth.current?.name ?? "")")
            isConnected = true
        case .disconnected:
            print("◦ disconnected")
            isConnected = false
        }
    }
    
    func list(list: [Bluetooth.Device]) { self.list = list }
    
    func value(data: Data) {
        response = data
        
        let sdFormatter = DateFormatter()
        sdFormatter.dateFormat = "MM/dd/yyyy, HH:mm aa"
        self.lastUpdated = sdFormatter.string(from: Date())
    }
    
    func rssi(value: Int) { rssi = value; print(value) }
}
