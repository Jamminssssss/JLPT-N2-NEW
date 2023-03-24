//
//  Home.swift
//  JLPT N2
//
//  Created by jaemin park on 2023/03/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct Home: View {
    @State private var quizInfo: Info?
    @State private var questions: [Question] = []
    @State private var startQuiz: Bool = false
    @AppStorage("log_status") private var logStatus: Bool = false
    var body: some View {
        if let info = quizInfo{
            VStack(spacing: 10){
                Text(info.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .hAlign(.leading)
                
                if !info.rules.isEmpty{
                    RulesView(info.rules)
                }
                
                CustomButton(title: "시작", onClick: {
                    startQuiz.toggle()
                })
                    .vAlign(.bottom)
            }
            .padding(15)
            .vAlign(.top)
            .fullScreenCover(isPresented: $startQuiz) {
                QuestionsView(info: info, questions: questions){
                    quizInfo?.peopleAttended += 1
                    
                }
            }
            
        }else{
            VStack(spacing: 4){
                ProgressView()
                Text("잠시만 기다려 주세요")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .task {
                do{
                    try await fetchData()
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @ViewBuilder
    func RulesView(_ rules: [String])->some View{
        VStack(alignment: .leading, spacing: 15) {
            Text("시작전에 읽어주세요.")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom,12)
            VStack {
                Link(destination: URL(string: "https://www.youtube.com/watch?v=AalZV-aUfSg")!, label: {
                    Text("소개 영상")
                        .font(.system(size: 30))
                        .frame(width: 300, height: 60)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding()
                })
            }

            ForEach(rules,id: \.self){rule in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(.black)
                        .frame(width: 8, height: 8)
                        .offset(y: 6)
                    Text(rule)
                        .font(.callout)
                        .lineLimit(3)
        
                }
            }
        }
    }
      
    
    @ViewBuilder
    func CustomLabel(_ image: String,_ title: String,_ subTitle: String)->some View{
        HStack(spacing: 12){
            Image(systemName: image)
                .font(.title3)
                .frame(width: 45, height: 45)
                .background{
                    Circle()
                        .fill(.gray.opacity(0.1))
                        .padding(-1)
                        .background{
                            Circle()
                                .stroke(Color("BG"),lineWidth: 1)
                        }
                }
            VStack(alignment: .leading, spacing: 4){
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BG"))
                Text(subTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            .hAlign(.leading)
        }
    }
    
    func fetchData()async throws{
        try await loginUserAnonymous()
        let info = try await Firestore.firestore().collection("Quiz").document("Info").getDocument().data(as: Info.self)
        let questions = try await
        Firestore.firestore().collection("Quiz").document("Info").collection("Questions").getDocuments().documents.compactMap{
            try $0.data(as: Question.self)
        }
        await MainActor.run(body: {
            self.quizInfo = info
            self.questions = questions
        })
    }
    
    func loginUserAnonymous()async throws{
        if !logStatus{
            try await Auth.auth().signInAnonymously()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

struct CustomButton: View{
    var title: String
    var onClick: ()->()
    
    var body: some View{
        Button {
           onClick()
        } label: {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .hAlign(.center)
                .padding(.top,15)
                .padding(.bottom,10)
                .foregroundColor(.green)
                .background {
                    Rectangle()
                        .fill(Color("Pink"))
                        .ignoresSafeArea()
                }
        }
        .padding([.bottom,.horizontal],-15)
        
    }
}


extension View{
    func hAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxWidth: .infinity,alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxHeight: .infinity,alignment: alignment)
    }
}
