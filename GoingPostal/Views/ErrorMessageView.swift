//
//  ErrorMessageView.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/16.
//

import SwiftUI
struct ErrorMessageView: View {
    
    @EnvironmentObject var postService: PostService
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text(postService.errorMessage)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .frame(maxWidth: .infinity)
                .lineLimit(2) // Limit text to 2 lines to avoid excessive height
        }.background(Color.red)
                    
    }
}

struct ErrorMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorMessageView().environmentObject(PostService.shared)
            .previewLayout(.sizeThatFits)
    }
}
