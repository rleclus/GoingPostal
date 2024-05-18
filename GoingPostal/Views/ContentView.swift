//
//  ContentView.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var postService: PostService
    @State private var isAddPostViewPresented = false
    @State private var expandedGroupIndex: Int? = nil // Track the index of the expanded group
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(postService.posts.indices, id: \.self) { index in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedGroupIndex == index },
                                set: { isExpanded in
                                    expandedGroupIndex = isExpanded ? index : nil
                                }
                            ),
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(postService.posts[index].body ?? "No Body")
                                        .font(.body)
                                        .lineLimit(nil)
                                }
                                .padding(.vertical, 8)
                            },
                            label: {
                                Text(postService.posts[index].title ?? "No Title")
                            }
                        )
                        .padding(.horizontal)
                    }
                    .onDelete(perform: deletePost)
                }
                .animation(.default, value: postService.posts.count)
                
                Button("Add Post") {
                    isAddPostViewPresented.toggle()
                }
                .padding()
            }
            .navigationBarTitle("")
            .navigationBarItems(leading: HStack {
                Text("Posts")
                    .font(.title) // Use .title2 for inline mode
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.leading)
                Image("postbox")
            }
            )
            .sheet(isPresented: $isAddPostViewPresented) {
                AddPostView(isPresented: $isAddPostViewPresented)
            }.onAppear(){
                Task(priority: .background) {
                    guard !ProcessInfo.processInfo.isRunningTests else { return }
                    await postService.fetchPostsAndUpdateCoreData()
                    postService.fetchStoredPosts()
                }
            }
        }
    }
    
    private func deletePost(at offsets: IndexSet) {
        offsets.forEach { index in
            let post = postService.posts[index]
            postService.deletePost(withTitle: post.title ?? "")
            postService.fetchStoredPosts()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PostManager.service)
    }
}
