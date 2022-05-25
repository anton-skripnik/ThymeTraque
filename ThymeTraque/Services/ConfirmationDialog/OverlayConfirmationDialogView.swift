//
//  OverlayConfirmationDialogView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import SwiftUI

struct OverlayConfirmationDialogView: ViewModifier {
    struct Action: Identifiable {
        let id = UUID()
        let title: String
        let isCancelling: Bool
        let closure: () -> Void
    }
    
    @Binding var isPresented: Bool
    var title: String?
    var message: String
    var textFieldBinding: Binding<String>?
    var actions: Array<Action>
    
    @State private var textCapture: String = ""
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Group {
                Color(.black)
                    .opacity(0.33)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        if let title = title {
                            Text(title)
                                .font(.title2)
                                .padding()
                        }
                        
                        Text(message)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .padding()
                        
                        if textFieldBinding != nil {
                            TextField("Enter here", text: $textCapture)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                        }
                        
                        HStack() {
                            Spacer()
                            
                            ForEach(actions) { action in
                                Button(action.title) {
                                    if !action.isCancelling {
                                        textFieldBinding?.wrappedValue = textCapture
                                    }
                                    
                                    action.closure()
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .background()
                    
                    Spacer()
                }
                .frame(maxWidth: 320.0)
                .animation(.none, value: isPresented)
            }
            .onChange(of: isPresented, perform: { value in
                if value {
                    textCapture = ""
                }
            })
            .opacity(isPresented ? 1 : 0)
            .animation(.easeInOut(duration: 0.33), value: isPresented)
        }
    }
}

extension View {
    func overlayConfirmationDialog(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String,
        textFieldBinding: Binding<String>? = nil,
        actions: Array<OverlayConfirmationDialogView.Action>
    ) -> some View {
        self.modifier(OverlayConfirmationDialogView(
            isPresented: isPresented,
            title: title,
            message: message,
            textFieldBinding: textFieldBinding,
            actions: actions
        ))
    }
}

struct OverlayConfirmationDialogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Color(.red)
                .overlayConfirmationDialog(
                    isPresented: .constant(true),
                    title: "Full house",
                    message: "Hello there",
                    textFieldBinding: .constant("Some text field"),
                    actions: [
                        .init(title: "OK", isCancelling: false, closure: {}),
                        .init(title: "Cancel", isCancelling: false, closure: {})
                    ]
                )
            
            Color(.green)
                .overlayConfirmationDialog(
                    isPresented: .constant(true),
                    message: "Hello there",
                    textFieldBinding: .constant("Some text field"),
                    actions: [
                        .init(title: "Accept", isCancelling: false, closure: {}),
                        .init(title: "Do not accept", isCancelling: false, closure: {})
                    ]
                )
            
            Color(.blue)
                .overlayConfirmationDialog(
                    isPresented: .constant(true),
                    title: "My custom title",
                    message: "Hello there",
                    actions: [
                        .init(title: "Accept", isCancelling: false, closure: {}),
                        .init(title: "Do not accept", isCancelling: false, closure: {})
                    ]
                )
                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
