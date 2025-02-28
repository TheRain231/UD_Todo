//
//  ProfileView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var vm = ProfileViewModel()
    
    var body: some View {
        NavigationStack{
            VStack {
                
                Text(vm.user.name)
                    .font(.system(size: 50, weight: .bold))
                    .padding()
                
                Spacer()
                
                Button {
                    vm.logout()
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
