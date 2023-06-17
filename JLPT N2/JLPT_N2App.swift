//
//  JLPT_N2App.swift
//  JLPT N2
//
//  Created by jaemin park on 2023/03/22.
//

import SwiftUI
import Firebase


@main
struct JLPT_N2App: App {
    
    init(){
            FirebaseApp.configure()

        }
        
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
