//
//  AddPostView.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import SwiftUI

struct AddPostView: View {
    @State private var showError = false
    @Binding var isPresented: Bool
    @EnvironmentObject var postService: PostService
    @State private var postTitle = ""
    @State private var postBody = ""
    
    var body: some View {
        VStack {
            if showError {
                HStack {
                    ErrorMessageView()
                        .background(Color.red)
                        .onAppear(){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation {
                                    showError = false
                                }
                            }
                        }
                }
                
            }
            NavigationView {
                Form {
                    Section(header: Text("Title")) {
                        TextField("Enter Title", text: $postTitle)
                    }
                    
                    Section(header: Text("Body")) {
                        TextEditor(text: $postBody)
                            .frame(height: 150)
                    }
                }
                .navigationBarTitle("Add Post")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        isPresented = false
                    },
                    trailing: Button("Save") {
                        if postService.addPost(userId: 1, id: Int(Date().timeIntervalSince1970), title: postTitle, body: postBody) {
                            postService.fetchStoredPosts()
                            isPresented = false
                        } else {
                            withAnimation(.easeOut(duration: 1)) {
                                showError = true
                            }
                        }
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView(isPresented: .constant(true))
            .environmentObject(PostManager.service)
            .previewLayout(.sizeThatFits)
    }
}

