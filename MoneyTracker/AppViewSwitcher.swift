//
//  AppViewSwitcher.swift
//  MoneyTracker
//
//  Created by Omar Khaled on 11/04/2022.
//

import SwiftUI

struct AppViewSwitcher: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
//        MainView()
        if UIDevice.current.userInterfaceIdiom == .phone{
            MainView()
        }else{
            if horizontalSizeClass == .compact{
                Color.blue
            }else{
                MainIpadView()
            }
        }
    }
}

struct AppViewSwitcher_Previews: PreviewProvider {
    static var previews: some View {
        AppViewSwitcher()
        
        AppViewSwitcher()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
            .environment(\.horizontalSizeClass, .regular)
            .previewInterfaceOrientation(.landscapeLeft)
        
        AppViewSwitcher()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
            .environment(\.horizontalSizeClass, .compact)
    }
}
