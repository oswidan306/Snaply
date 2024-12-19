//
//  ContentView.swift
//  Snaply
//
//  Created by Omar Swidan on 12/15/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = DiaryViewModel()
    @StateObject private var slideViewModel = SlideViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var activeTextId: UUID?
    @State private var isTyping: Bool = false
    @State private var showingEmotionPicker = false
    @State private var isDraggingUp = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                Color(hex: "#FBFBFB").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Fixed Header
                    HeaderView(slideViewModel: slideViewModel)
                        .zIndex(1)
                    
                    // Sliding Content
                    VStack(spacing: 0) {
                        DateComponent()
                            .padding(.top, 16)
                        
                        if let _ = viewModel.currentEntry {
                            PhotoCanvasView(
                                viewModel: viewModel,
                                activeTextId: $activeTextId,
                                isTyping: $isTyping
                            )
                            .padding(.top, 16)
                        } else {
                            PhotoPickerView(selectedItem: $selectedItem)
                                .padding(.top, 16)
                        }
                        
                        Spacer()
                        
                        Text("PAST")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                            .monospaced()
                            .tracking(2)
                            .padding(.bottom, 16)
                    }
                    .offset(y: slideViewModel.slideOffset)
                }
                
                // Calendar View
                VStack {
                    Spacer()
                    MonthCalendarView()
                        .padding(.horizontal)
                        .frame(height: geometry.size.height * 0.9)
                        .background(Color(hex: "#FBFBFB"))
                        .offset(y: min(geometry.size.height - slideViewModel.slideOffset, geometry.size.height))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.height
                        if translation < 0 { // Dragging up
                            isDraggingUp = true
                            slideViewModel.slideOffset = translation
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.height
                        let threshold: CGFloat = geometry.size.height * 0.2
                        
                        if translation < -threshold {
                            slideViewModel.showCalendar()
                        } else {
                            slideViewModel.hideCalendar()
                        }
                        isDraggingUp = false
                    }
            )
        }
        .onChange(of: selectedItem) { newItem in
            if let item = newItem {
                loadImage(from: item)
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            if let imageData = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                await MainActor.run {
                    viewModel.addNewPhoto(uiImage)
                }
            }
            await MainActor.run {
                selectedItem = nil
            }
        }
    }
}
