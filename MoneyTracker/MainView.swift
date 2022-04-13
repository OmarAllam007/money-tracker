//
//  MainView.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 22/03/2022.
//

import SwiftUI



struct MainView: View {
    
    @State private var showAddNewCardForm:Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    
    private var cards: FetchedResults<Card>
    
    @State private var selectedCardHash = -1
    @State private var selectedIndex = 1
    
    
   
    var body: some View {
        
        NavigationView{
            
            ScrollView{
                if(!cards.isEmpty){
                    TabView(selection: $selectedCardHash){
                        ForEach (cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom,50)
                                .tag(card.hash)
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .onAppear {
                        self.selectedCardHash = cards.first?.hash ?? -1
                    }
                }
                
                 
                if let firstIndex = cards.firstIndex(where: {$0.hash == self.selectedCardHash}) {
                    let card = cards[firstIndex]
                    CardTransactionListView(card:card)
                }
                
                
                Spacer()
                    .fullScreenCover(isPresented: $showAddNewCardForm, onDismiss: nil) {
                        AddNewCardForm(card: nil) { card in
                            self.selectedCardHash = card.hash 
                        }
                    }
                
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(trailing:addButton)
        }
    }
    
    
    
    var emptyViewMessage: some View {
        VStack{
            Text("You have currently no cards in the system.")
                .font(.system(size: 22, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding()
            Button {
                showAddNewCardForm.toggle()
            } label: {
                Text("+ Add your first card")
                    .foregroundColor(Color(.systemBackground))
                
            }
            .padding()
            .background(Color(.label))
            .cornerRadius(5)
            
        }.font(.system(size: 22))
    }
    
    var addItemButton: some View {
        Button(action: {
            //            showAddNewCardForm.toggle()
        }, label:{
            Text("Add Item")
            //                .fore  erRadius(5)
        })
        
    }
    
    var addButton: some View {
        Button(action: {
            showAddNewCardForm.toggle()
        }, label:{
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(.black)
                .cornerRadius(5)
        })
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, context)
    }
}

struct CreditCardView: View {
    let card:Card
    var fetchRequest:FetchRequest<CardTransaction>
    
    init(card:Card){
        self.card = card
        
        self.fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @State private var shouldShowActionSheet = false
    @State private var showEditNewCardForm:Bool = false
    
    @State private var refreshID = UUID()
    
    private func handleDelete(){
        let context = PersistenceController.shared.container.viewContext
        context.delete(card)
        
        do{
            try context.save()
        }catch{
            print("Cannot delete the card \(card.name ?? "")")
        }
    }
    
    var body: some View {
        
        withAnimation {
            VStack(alignment: .leading, spacing: 15){
                HStack{
                    Text(card.name ?? "")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()

                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .actionSheet(isPresented: $shouldShowActionSheet) {
                        .init(title: Text(self.card.name ?? ""),
                              message: Text(""),
                              buttons: [
                                .default(Text("Edit"),action: {
                                    showEditNewCardForm.toggle()
                                }),
                                .cancel(),
                                .destructive(Text("Delete"), action: handleDelete)
                              ])
                    }
                }
                
                HStack{
                    Image("visa")
                        .resizable()
                        .scaledToFit()
                        .frame(height:44)
                    
                    Spacer()
                    
                    if let total = fetchRequest.wrappedValue.reduce(0, {$0 + $1.amount})
                    {
                        Text("Total: $\(String(format: "%.2f", total))")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                }
                
                Text(card.number ?? "")
                if let total = fetchRequest.wrappedValue.reduce(0, {$0 + $1.amount})
                {
                Text("Credit Limit: $\(String(format: "%.2f", Float(card.limit) - Float(total)))")
                }
                HStack{ Spacer() }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                
                VStack{
                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData),
                       let actualColor = Color(uiColor: uiColor){
                        LinearGradient(colors: [
                            actualColor , actualColor.opacity(0.6)
                        ], startPoint: .bottom, endPoint: .top)
                    }else{
                        Color.purple
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.6)  , lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top,8)
            
        }
    }
    
}
