//
//  AddNewTransaction.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 25/03/2022.
//

import SwiftUI

struct AddNewTransaction: View {
    let card:Card
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showImagePickerView = false
    
    
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    
    @State private var inputImage: UIImage?
    
    @State private var selectedTags = Set<TransactionTag>()
    
    var body: some View {
        NavigationView{
            Form{
                Section {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date,displayedComponents: .date)
                    
                    NavigationLink {
//                        to pass context to view
                        SelectTransactionTag(selectedTags: $selectedTags)
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                            .navigationTitle("Tags")
                    } label: {
                        Text("Tags")
                        
                    }
                    
                    let sortedTagsArray = Array(selectedTags).sorted(by: {$0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending})
                    
                    ForEach(sortedTagsArray){ tag in
                
                        HStack(spacing:12){
                            if let colorData = tag.color, let color = UIColor.color(data: colorData) {
                                let lastColor = Color(uiColor: color)
                                Spacer()
                                    .frame(width: 30, height: 20)
                                    .background(lastColor)
                            }
                            Text(tag.name ?? "")
                        }
                    }
                    
                } header: {
                    Text("INFORMATION")
                }
                
                Section {
                    Button {
                        showImagePickerView.toggle()
                    } label: {
                        Text("Select Photo")
                    }
                    
                    if inputImage != nil {
                        
                        Image(uiImage: inputImage!)
                            .resizable()
                            .scaledToFit()
                    }
                    
                } header: {
                    Text("Attachments")
                }
                
                
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: saveTransaction, label: {
                Text("Save")
            }))
            
        }.fullScreenCover(isPresented: $showImagePickerView) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func saveTransaction(){
        let context = PersistenceController.shared.container.viewContext
        let transaction = CardTransaction(context: context)
        
        transaction.name = self.name
        transaction.amount = Float(self.amount) ?? 0
        transaction.timestamp = Date()
        transaction.photoData = inputImage?.jpegData(compressionQuality:0.5)
        transaction.card = self.card
        transaction.tags = self.selectedTags as NSSet
        
        do{
            try context.save()
            presentationMode.wrappedValue.dismiss()
        }catch{
            print("Error in saving the transaction \(error.localizedDescription)")
        }
    }
}



struct AddNewTransaction_Previews: PreviewProvider {
    static let card:Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request  = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        if let card = card {
            AddNewTransaction(card: card)
        }
    }
}
