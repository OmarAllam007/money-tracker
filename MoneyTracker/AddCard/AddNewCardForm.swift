//
//  AddCardForm.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 22/03/2022.
//

import SwiftUI

struct AddNewCardForm : View {
    @Environment(\.presentationMode) var presentationMode
    
    let card:Card?
    
    var cardAdded:((Card)-> ())? = nil
    
    init(card:Card? = nil, cardAdded: ((Card)-> ())? = nil) {
        self.card = card
        self.cardAdded = cardAdded
        
        _name = State(initialValue: self.card?.name ?? "")
        _creditNumber = State(initialValue: self.card?.number ?? "")
        _type = State(initialValue: self.card?.type ?? "")
        
        if let limit = self.card?.limit {
            _limit = State(initialValue: String(limit))
        }
        
        _month = State(initialValue: Int(self.card?.expMonth ?? 1))
        _year = State(initialValue: Int(self.card?.expYear ?? Int16(currentYear)))
        
        if let data = self.card?.color, let uicolor = UIColor.color(data: data) {
            let c = Color(uiColor: uicolor)
            _color = State(initialValue: c)
        }
        
    }
    
    @State private var name = ""
    @State private var creditNumber = ""
    @State private var limit = ""
    @State private var type = "Visa"
    @State private var month = 1
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var color = Color.blue
    
    let currentYear = Calendar.current.component(.year, from: Date())
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView{
            Form{
                Section {
                    TextField("Name",text:$name).focused($isFocused)
                    
                    
                    
                    TextField("Credit Card Number",text:$creditNumber)
                        .keyboardType(.numberPad)
                    TextField("Credit Limit",text:$limit)
                        .keyboardType(.numberPad)
                    
                    Picker(selection: $type) {
                        ForEach(["Visa","Mastercard","Discover"],id:\.self){ type in
                            Text(String(type)).tag(String(type))
                        }
                    } label: {
                        Text("Type")
                    }
                    
                } header: {
                    Text("Card Info")
                }.onAppear {
                    self.isFocused = true
                }
                
                
                Section {
                    Picker(selection: $month) {
                        ForEach(1..<13,id:\.self){ num in
                            Text(String(num)).tag(String(num))
                        }
                    } label: {
                        Text("Month")
                    }
                    
                    Picker(selection: $year) {
                        ForEach(currentYear..<currentYear+20,id:\.self){ num in
                            Text(String(num)).tag(String(num))
                        }
                    } label: {
                        Text("Year")
                    }
                } header: {
                    Text("Expiration")
                }
                
                Section {
                    ColorPicker("Color", selection: $color)
                } header: {
                    Text("Color")
                }
                
            }
            .navigationTitle(self.card != nil ? self.card?.name ?? "" : "Add New Card")
            .navigationBarItems(leading: cancelButtonView, trailing: saveButtonView)
        }
    }
    
    var cancelButtonView: some View {
        Button(action:{
            presentationMode.wrappedValue.dismiss()
            
        }, label:{
            Text("Cancel")
        })
    }
    
    var saveButtonView: some View {
        Button(action:{
            let viewContext = PersistenceController.shared.container.viewContext
            let card = self.card != nil ? self.card! : Card(context: viewContext)
            
            card.uuid = UUID()
            card.name = self.name
            card.number = self.creditNumber
            card.limit = Int32(self.limit) ?? 0
            card.expMonth = Int16(self.month)
            card.expYear = Int16(self.year)
            card.timestamp = Date()
            card.color = UIColor(self.color).encode()
            
            
            do {
                try viewContext.save()
                
                
                presentationMode.wrappedValue.dismiss()
                cardAdded?(card)
            }catch{
                print("Error when saving \(error.localizedDescription)")
            }
            
        }, label:{
            Text("Save")
        })
    }
}
struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, context)
    }
}


extension UIColor {
    
    class func color(data:Data)-> UIColor?{
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
    
    func encode() -> Data?{
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
