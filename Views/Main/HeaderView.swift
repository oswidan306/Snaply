//
//  HeaderView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var slideViewModel: SlideViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Reduced top spacing
            Rectangle()
                .fill(.clear)
                .frame(height: 24)
            
            HStack {
                Image("calendar_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .onTapGesture {
                        if slideViewModel.isShowingCalendar {
                            slideViewModel.hideCalendar()
                        } else {
                            slideViewModel.showCalendar()
                        }
                    }
                
                Spacer()
                
                Image("connections_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            .padding(.horizontal)
        }
        .background(
            Color(hex: "#FBFBFB")
                .opacity(1)
                .blur(radius: 16)
                .ignoresSafeArea(edges: .top)
        )
    }
}

