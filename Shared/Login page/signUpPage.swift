//
//  signUpPage.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 10/19/22.
//

import SwiftUI

struct signUpPage: View {
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = "Something isn't right on your end"
    @State private var signupLabel:String = "Sign up"
    @State private var signupDisable = false
    
    @State private var firstNameValue: String = ""
    @State private var lastNameValue: String = ""
    @State var genderIndex: Int? = nil
    @State private var birthDateValue = Date()
    @State private var artistNameValue: String = ""
    @State private var emailValue: String = ""
    @State private var passwordValue: String = ""
    
    @FocusState private var firstNameInputFocused: Bool
    @FocusState private var lastNameInputFocused: Bool
    @FocusState private var artistNameInputFocused: Bool
    @FocusState private var emailInputFocused: Bool
    @FocusState private var passwordInputFocused: Bool
    
    let genders = ["Male", "Female", "Other"]
    
    var signupIsValid: Bool {
        if (firstNameValue == "" || lastNameValue == "" || genderIndex == nil || artistNameValue == "" || emailValue == "" || passwordValue == "" || signupDisable) {
            return false
        }else {
            return true
        }
    }
    
    let verticalPaddingForForm = 40.0
    var body: some View {
        ScrollView{
            VStack(spacing: CGFloat(verticalPaddingForForm)) {
                Group{
                    Text("Sign up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    HStack {
                        Image(systemName: "person")
                            .font(Font.headline.weight(.bold))
                        TextField("", text: $firstNameValue)
                            .textContentType(.givenName)
                            .font(Font.headline.weight(.bold))
                            .focused($firstNameInputFocused)
                            .placeholder(when: firstNameValue.isEmpty) {
                                Text("First name").fontWeight(.bold).opacity(0.25)
                            }
                    }
                    .padding()
                    .background(Color("BlackWhite").opacity(0.1))
                    .cornerRadius(100)
                    .onTapGesture {
                        firstNameInputFocused = true
                    }
                    HStack {
                        Image(systemName: "person")
                            .font(Font.headline.weight(.bold))
                        TextField("", text: $lastNameValue)
                            .textContentType(.familyName)
                            .font(Font.headline.weight(.bold))
                            .focused($lastNameInputFocused)
                            .placeholder(when: lastNameValue.isEmpty) {
                                Text("Last name").fontWeight(.bold).opacity(0.25)
                            }
                    }
                    .padding()
                    .background(Color("BlackWhite").opacity(0.1))
                    .cornerRadius(100)
                    .onTapGesture {
                        lastNameInputFocused = true
                    }
                }
                HStack{
                    Image(systemName: "person.2")
                    PickerField("Gender", data: self.genders, selectionIndex: self.$genderIndex)
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                VStack{
                    DatePicker(selection: $birthDateValue, in: ...Date(), displayedComponents: .date) {
                        HStack{
                            Image(systemName: "calendar")
                            Text("Birthdate").fontWeight(.bold).opacity(0.25)
                        }
                    }
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                HStack {
                    Image(systemName: "person")
                        .font(Font.headline.weight(.bold))
                    TextField("", text: $artistNameValue)
                        .font(Font.headline.weight(.bold))
                        .focused($artistNameInputFocused)
                        .placeholder(when: artistNameValue.isEmpty) {
                            Text("Artist name eg. Phyno, Cardi B").fontWeight(.bold).opacity(0.25)
                                .lineLimit(1)
                        }
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                .onTapGesture {
                    artistNameInputFocused = true
                }
                HStack {
                    Image(systemName: "mail")
                        .font(Font.headline.weight(.bold))
                    TextField("", text: $emailValue)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .font(Font.headline.weight(.bold))
                        .focused($emailInputFocused)
                        .placeholder(when: emailValue.isEmpty) {
                            Text("Email").fontWeight(.bold).opacity(0.25)
                        }
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                .onTapGesture {
                    emailInputFocused = true
                }
                HStack {
                    Image(systemName: "key")
                        .font(Font.headline.weight(.bold))
                    SecureField("", text: $passwordValue)
                        .textContentType(.password)
                        .font(Font.headline.weight(.bold))
                        .focused($passwordInputFocused)
                        .placeholder(when: passwordValue.isEmpty) {
                            Text("Password").fontWeight(.bold).opacity(0.25)
                        }
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                .onTapGesture {
                    passwordInputFocused = true
                }
                Spacer()
                Button{
                    //
                } label: {
                    Text(signupLabel)
                        .foregroundColor((signupIsValid) ? Color("WhiteBlack") : Color.white)
                        .padding()
//                        .frame(width: viewableWidth - 80)
                }
                .background((signupIsValid) ? Color("BlackWhite") : Color(hexStringToUIColor(hex: "#aaaaaa")))
                .cornerRadius(100)
                .disabled((signupIsValid) ? false : true)
                .padding(.bottom, 50)
                
            }
            .padding(.horizontal, CGFloat(verticalPaddingForForm))
            .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
                Button("OK", role: .cancel, action: {})
            }, message: {
                Text(presentAlertMessage)
            })
        }
    }
}

struct signUpPage_Previews: PreviewProvider {
    static var previews: some View {
        signUpPage()
    }
}
