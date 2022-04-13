//
//  CardTransactionView.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 27/03/2022.
//

import SwiftUI

struct CardTransactionView: View {
    let transaction:CardTransaction
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    @State private var showActionSheetView = false
    
    
    func deleteTransaction(){
        withAnimation(.easeInOut) {
            let context = PersistenceController.shared.container.viewContext
            context.delete(transaction)
            
            do{
                try context.save()
            }catch{
                print("Error while delete transaction")
            }
        }
        
        
    }

    
    var body: some View {
        
        VStack {
            HStack {
                VStack {
                    Text(transaction.name ?? "")
                        .font(.system(size: 16, weight: .bold))
                    if let date = transaction.timestamp {
                        Text(dateFormatter.string(from: date))
                    }

                }
                Spacer()
                VStack {
                    Button {
                        showActionSheetView.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22))
                    }
                    .confirmationDialog(Text(transaction.name ?? ""), isPresented: $showActionSheetView,titleVisibility: Visibility.visible ,actions: {
                        
                        Button(role: .destructive) {
                            deleteTransaction()
                        } label: {
                            Text("Delete")
                        }

                        Button(role: .cancel) {
                            
                        } label: {
                            Text("Cancel")
                        }

                    })
                    .padding(EdgeInsets.init(top: 6, leading: 8, bottom: 4, trailing: 0))
                    

                    Text(String(format: "$%0.f", transaction.amount))

                }
            }
                
            if let tags = transaction.tags as? Set<TransactionTag> {
                let tagsArray = Array(tags).sorted(by: {$0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending})
                
                
                HStack{
                    ForEach(tagsArray, id: \.self){ tag in
                        
                        if let colorData = tag.color, let color = UIColor.color(data: colorData) {
                            let lastColor = Color(uiColor: color)
                            Text(tag.name ?? "")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.vertical,6)
                                .padding(.horizontal,16)
                                .background(lastColor)
                                .cornerRadius(10)
                        }
                        
                        
                    }
                    Spacer()
                }
                
            }
            
            if let data = transaction.photoData, let uiimage = UIImage(data: data) {
                Image(uiImage: uiimage)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(10)
            }

        }
        .foregroundColor(Color(.label))
        .padding()
        .background(Color("TransactionBG"))
        .cornerRadius(10)
        .shadow(radius: 1)
        .padding()
        
    }
}

//struct CardTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let transaction = CardTransaction()
//        transaction.name = "Test Card"
//        return CardTransactionView(transaction: transaction)
//    }
//}
