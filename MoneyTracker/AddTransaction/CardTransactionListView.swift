//
//  CardTransactionListView.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 27/03/2022.
//

import SwiftUI

struct CardTransactionListView: View {
    
    let card:Card
    var fetchRequest:FetchRequest<CardTransaction>
    
    init(card:Card) {
        self.card = card
        
        self.fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @State private var showAddNewTransaction: Bool = false
    @State private var showFilterSheet: Bool = false
    var body: some View {
        VStack {
            VStack{
                if fetchRequest.wrappedValue.isEmpty {
                    Text("Create you transactions related to the credit card")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    
                    addTransactionButton
                }
                else{
                    HStack{
                        Spacer()
                        addTransactionButton
                        addFilterButton
                            .sheet(isPresented: $showFilterSheet) {
                                FilterSheet(selectedTags:$selectedTags){ tags in
                                    self.selectedTags = tags
                                }
                            }
                    }.padding()
                }
                
            }
        
            ForEach(filterTransactions(selectedTags: self.selectedTags)) { transaction in
                CardTransactionView(transaction:transaction)
            }
        
        }.fullScreenCover(isPresented: $showAddNewTransaction) {
            AddNewTransaction(card:card)
        }
    }
    
    
    @State var selectedTags = Set<TransactionTag>()
    
    private func filterTransactions(selectedTags:Set<TransactionTag>) -> [CardTransaction]{
        if selectedTags.isEmpty{
            return Array(fetchRequest.wrappedValue)
        }
        
        return fetchRequest.wrappedValue.filter { transaction in
            var shouldReturn = false
            
            if let tags = transaction.tags as? Set<TransactionTag>{
                tags.forEach({ tag in
                    if selectedTags.contains(tag) {
                        shouldReturn = true
                    }
                })
            }
            
            return shouldReturn
        }
    }
    
    var addFilterButton:some View{
        Button {
            showFilterSheet.toggle()
        } label: {
            HStack{
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Filter")
            }
            .foregroundColor(Color(.systemBackground))
            .padding(.vertical,8)
            .padding(.horizontal,12)
            .background(Color(.label))
            .cornerRadius(5)
        }
    }
    
    var addTransactionButton:some View{
        Button {
            showAddNewTransaction.toggle()
        } label: {
            Text("+ Add Transaction")
                .foregroundColor(Color(.systemBackground))
                .padding(.vertical,8)
                .padding(.horizontal,12)
                .background(Color(.label))
                .cornerRadius(5)
        }
    }
    
}

struct FilterSheet:View{
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionTag.timestamp, ascending: false)],
        animation: .default)
    
    private var tags: FetchedResults<TransactionTag>
    
    @Binding var selectedTags:Set<TransactionTag>
    
    let didFilter:(Set<TransactionTag>) -> ()
    
    var body: some View {
        NavigationView{
            Form{
                Section{
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
                    }
                }
            }.navigationTitle("Select Filters")
                .toolbar {
                    ToolbarItem {
                        Button {
                            didFilter(selectedTags)
                            presentationMode.wrappedValue.dismiss()
                            
                        } label: {
                            Text("Filter")
                        }
                    }
                }
        }
    }
}

struct CardTransactionListView_Previews: PreviewProvider {
    static let card:Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request  = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        
        return try? context.fetch(request).first
    }()
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        
        ScrollView{
            if let card = card {
                CardTransactionListView(card: card)
                    .preferredColorScheme(.dark)
                    .environment(\.managedObjectContext, context)
            }
        }
        
    }
}
