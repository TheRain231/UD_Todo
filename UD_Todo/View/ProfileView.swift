//
//  ProfileView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var vm = ProfileViewModel()
    @AppStorage("isAuthenticated") var isAuthenticated = false
    
    var body: some View {
        NavigationStack{
            VStack {
                Button {
                    vm.logout()
                    isAuthenticated = false
                } label: {
                    HStack {
                        Text("Выйти")
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        
    }
}

#Preview {
    ProfileView()
}
