import SwiftUI

struct GalleryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.entries.isEmpty {
                EmptyStateView()
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(viewModel.entries) { entry in
                        EntryCard(entry: entry)
                            .aspectRatio(3/4, contentMode: .fit)
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "#F5F5F5"))
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No entries yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Text("Your memories will appear here")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EntryCard: View {
    let entry: Models.PhotoEntry
    
    var body: some View {
        Image(uiImage: entry.photo)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
    }
} 