//
//  QuestionsView.swift
//  JLPT N2
//
//  Created by jaemin park on 2023/03/22.
//

import SwiftUI
import FirebaseFirestore


struct QuestionsView: View {
    var info: Info
    @State var questions: [Question]
    var onFinish: ()->()
    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var score: CGFloat = 0
    @State private var showScoreCard: Bool = false
    var body: some View {
        VStack{
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .hAlign(.leading)
            
            Text(info.title)
                .font(.title)
                .fontWeight(.semibold)
                .hAlign(.leading)
            
            GeometryReader{
                let size = $0.size
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.2))
                    
                    Rectangle()
                        .fill(Color(.green))
                        .frame(width: progress * size.width,alignment: .leading)
                }
                .clipShape(Capsule())
            }
            .frame(height: 20)
            .padding(.top,5)
            
            GeometryReader{
                let size = $0.size
                
                ForEach(questions.indices,id: \.self) { index in
                    if currentIndex == index{
                        QuestionView(questions[currentIndex])
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
            }
            .padding(.horizontal,-15)
            .padding(.vertical,15)
            
            CustomButton(title: currentIndex == (questions.count - 1) ? "끝" : "다음 문제") {
                if currentIndex == (questions.count - 1){
                    showScoreCard.toggle()
                }else{
                    withAnimation(.easeInOut){
                        currentIndex += 1
                        progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
                    }
                }
            }
        }
        .padding(15)
        .hAlign(.center).vAlign(.top)
        .background {
            Color.white.ignoresSafeArea()
        }
        .environment(\.colorScheme, .dark)
        .fullScreenCover(isPresented: $showScoreCard) {
            ScoreCardView(score: score / CGFloat(questions.count) * 100) {
                dismiss()
                onFinish()
            }
        }
    }
    
    @ViewBuilder
    func QuestionView(_ question: Question)->some View{
        VStack(alignment: .leading, spacing: 15) {
            Text("Question \(currentIndex + 1)/\(questions.count)")
                .font(.callout)
                .foregroundColor(.gray)
                .hAlign(.leading)
            
            Text(question.question)
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 12){
                ForEach(question.options,id: \.self){option in
                    ZStack{
                        OptionView(option, .black)
                            .opacity(question.answer == option && question.tappedAnswer != "" ? 0 : 1)
                        OptionView(option, .green)
                            .opacity(question.answer == option && question.tappedAnswer != "" ? 1 : 0)
                        OptionView(option, .red)
                            .opacity(question.tappedAnswer == option && question.tappedAnswer != question.answer ? 1 : 0)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard questions[currentIndex].tappedAnswer == "" else{return}
                        withAnimation(.easeInOut){
                            questions[currentIndex].tappedAnswer = option
                            
                            if question.answer == option{
                                score += 1.0
                            }
                        }
                    }
                }
            }
            .padding(.vertical,10)
        }
        .padding(15)
        .hAlign(.center)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
        }
      
        .padding(.horizontal,15)
    }
    
    @ViewBuilder
    func OptionView(_ option: String,_ tint: Color)->some View{
        Text(option)
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 15))
            .foregroundColor(tint)
            .padding(.horizontal,5)
            .padding(.vertical,10)
            .hAlign(.leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.15))
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(tint.opacity(tint == .gray ? 0.15 : 1),lineWidth: 2)
                    }
            }
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ScoreCardView: View{
    var score: CGFloat
    var onDismiss: ()->()
    @Environment(\.dismiss) private var dismiss
    var body: some View{
        VStack{
            VStack(spacing: 15){
                Text("시험이 끝났습니다.")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                VStack(spacing: 15){
                    Text("당신의\n 정답률은?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(String(format: "%.0f", score) + "%")
                        .font(.title.bold())
                        .padding(.bottom,10)
                    
                    Image("Medal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                   
                  
                    Link(destination: URL(string: "https://www.youtube.com/watch?v=aBkXWvOzHfA")!, label: {
                        Text("기획의도")
                            .font(.system(size: 30))
                            .frame(width: 300, height: 60)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding()
                    })
                    
                    Link(destination: URL(string: "https://www.youtube.com/watch?v=vg-OkwsC1Tk")!, label: {
                        Text("샘플강의")
                            .font(.system(size: 30))
                            .frame(width: 300, height: 60)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding()
                    })
                    

                }
                .foregroundColor(.black)
                .padding(.horizontal,15)
                .padding(.vertical,20)
                .hAlign(.center)
                .background {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(.white)
                }
            }
            .vAlign(.center)
            
            CustomButton(title: "다시 시작") {
                
                Firestore.firestore().collection("Quiz").document("Info").updateData([
                    "peopleAttended": FieldValue.increment(1.0)
                ])
                onDismiss()
                dismiss()
            }
        }
        .padding(15)
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
    }
}


