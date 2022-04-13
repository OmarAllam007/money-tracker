//
//  SelectTransactionTag.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 08/04/2022.
//

import SwiftUI

struct SelectTransactionTag: View {
    @State private var name = ""
    @State private var color = Color.red
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionTag.timestamp, ascending: false)],
        animation: .default)
    
    private var tags: FetchedResults<TransactionTag>
    
    
    @Binding  var selectedTags:Set<TransactionTag>
    
    var body: some View {
        Form{
            Section {
                if(tags.count > 0){
                    ForEach(tags){ tag in
                        
                        Button {
                            if selectedTags.contains(tag){
                                selectedTags.remove(tag)
                            }else{
                                selectedTags.insert(tag)
                            }
                        } label: {
                            HStack(spacing:12){
                                if let colorData = tag.color, let color = UIColor.color(data: colorData) {
                                    let lastColor = Color(uiColor: color)
                                    Spacer()
                                        .frame(width: 30, height: 20)
                                        .background(lastColor)
                                }
                                
                                Text(tag.name ?? "")
                                    .foregroundColor(Color(.label))
                                Spacer()
                                
                                if selectedTags.contains(tag){
                                    Image(systemName: "checkmark")
                                }
                            }
                        }

                
                        
                    }.onDelete { indexSet in
                        indexSet.forEach{ i in
                            let tag = tags[i]
                            selectedTags.remove(tag)
                            viewContext.delete(tag)
                        }
                        try? viewContext.save()
                    }
                }
                else{
                    Text("No Tags found!")
                }
                
            } header: {
                Text("Select Tags")
            }
            
            
            Section {
                TextField("Name", text: $name)
                ColorPicker("Color", selection: $color)
                
                Button {
                    handleCreateTag()
                } label: {
                    HStack{
                        Spacer()
                        Text("Create")
                            .foregroundColor(.white)
                        Spacer()
                    }.padding(.vertical,5)
                        .background(.blue)
                        .cornerRadius(5)
                    
                    
                }.buttonStyle(.plain)
            } header: {
                Text("Create New Tag")
            }
        }
    }
    
    private func handleCreateTag(){
        let context = PersistenceController.shared.container.viewContext
        let tag = TransactionTag(context: context)
        tag.name = self.name
        tag.color = UIColor(color).encode()
        tag.timestamp = Date()
        
        try? context.save()
        
    }
}

struct SelectTransactionTag_Previews: PreviewProvider {
    static var previews: some View {
        SelectTransactionTag(selectedTags:.constant(.init()))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
