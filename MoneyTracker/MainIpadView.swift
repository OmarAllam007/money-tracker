//
//  MainIpadView.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 11/04/2022.
//

import SwiftUI

struct MainIpadView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    
    private var cards: FetchedResults<Card>
    
    @State private var selectedCard:Card?
    
    @State private var showAddCardSheet = false
    var body: some View {
        NavigationView{
            ScrollView{
                ScrollView(.horizontal,showsIndicators: false){
                    HStack{
                        ForEach (cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom,50)
                                .tag(card.hash)
                                .frame(width:400)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedCard = card
                                    }
                                }
                                .scaleEffect(self.selectedCard == card ? 1.10 : 1)
                        }
                    }.onAppear {
                        self.selectedCard = cards.first
                    }
                    .padding()
                    .frame(height:300)
                }
                
                if let card = self.selectedCard{
                    TransactionGrid(card: card)
                        .background(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
            }
            .navigationTitle("Money Tracker")
            .navigationBarItems(trailing: addTooBarButton)
            .sheet(isPresented: $showAddCardSheet) {
                AddNewCardForm(card: nil, cardAdded: nil)
            }
            .background(Color.gray.opacity(0.3))
        }.navigationViewStyle(.stack)
            
    }
    
    var addTooBarButton:some View{
        Button {
            showAddCardSheet.toggle()
        } label: {
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(.black)
                .cornerRadius(5)
        }
    }
}

struct TransactionGrid :View {
    let card:Card
    var fetchRequest:FetchRequest<CardTransaction>
    
    
    @State private var showTransactionForm = false
    init(card:Card) {
        self.card = card
        
        self.fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    var body: some View{
        VStack{
            HStack{
                Text("Transactions")
                Spacer()
                Button{
                    self.showTransactionForm.toggle()
                } label: {
                    Text("+ Create")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .background(.black)
                        .cornerRadius(5)
                }
            }.sheet(isPresented: $showTransactionForm) {
                AddNewTransaction(card: card)
            }
            
            let columns:[GridItem] = [
                .init(.fixed(100), spacing: 12,alignment:.leading),
                .init(.fixed(200), spacing: 12,alignment:.leading),
                .init(.adaptive(minimum: 300, maximum: 500), spacing: 12),
                .init(.flexible(minimum: 100, maximum: 450), spacing: 16,alignment:.trailing)
            ]
            
            LazyVGrid(columns: columns) {
                HStack{
                    Text("Date")
//                    Image(systemName: "arrow.up.arrow.down")
                }

                Text("Image")
                
                HStack {
                    Text("Name")
//                    Image(systemName: "arrow.up.arrow.down")
                    Spacer()
                }
                
                HStack {
                    Text("Amount")
//                    Image(systemName: "arrow.up.arrow.down")
                }
                
            }.foregroundColor(.black.opacity(0.8))
                .padding()
                .background(.gray.opacity(0.2))
                .cornerRadius(10)
            
            
            if let transactions = fetchRequest.wrappedValue {
                ForEach(transactions){ transaction in
                    LazyVGrid(columns: columns) {
                        HStack{
                            if let date = transaction.timestamp {
                                Text(dateFormatter.string(from: date))
                            }else{
                                Text("")
                            }
                            
                        }

                        if let imageData = transaction.photoData, let uiimage = UIImage(data: imageData){
                            Image(uiImage: uiimage)
                                .resizable()
                                .scaledToFit()
                                .frame(height:100)
                                .cornerRadius(10)
                                
                                
                        }else{
                            Text("")
                        }
                        
                        HStack {
                            Text(transaction.name ?? "")
                            Spacer()
                        }
                        
                        HStack {
                            Text(String(format: "%.2f", transaction.amount))
                        }
                        
                    }
                    if transaction != card.transactions?.reversed().last as! FetchedResults<CardTransaction>.Element{
                        Divider()
                    }
                    
                }
                .padding(.horizontal)
                if fetchRequest.wrappedValue.count == 0 {
                    Text("No Transactions found!")
                        .padding()
                }
            }
            
            
        }.padding()
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct MainIpadView_Previews: PreviewProvider {
    static var previews: some View {
        MainIpadView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
            .environment(\.horizontalSizeClass, .regular)
//            .previewInterfaceOrientation(.landscapeLeft)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
