//
//  ContentView.swift
//  TicTacToeGame
//
//  Created by Aji_sahputra on 15/11/20.
//

import SwiftUI
import Combine

enum SquareStatus {
  case empty
  case visitor
  case home
}

struct Square {
    var status: SquareStatus
}

class ModelBoard: ObservableObject {
  @Published var squares = [Square]()
  init() {
    for _ in 0...8 {
      squares.append(Square(status: .empty)) //tambahkan 9 kotak ke array
    }
  }
  
  func resetGame() { //setel ulang semua kotak menjadi kosong
    for i in 0...8 {
      squares[i].status = .empty
    }
  }
  
  var gameOver : (SquareStatus, Bool) { //periksa game over
    get {
      if thereIsAWinner != .empty {
        return (thereIsAWinner, true)
      } else {
        for i in 0...8 {
          if squares[i].status == .empty {
            return (.empty, false)
          }
        }
        return (.empty, true)
      }
    }
  }
  
  private var thereIsAWinner: SquareStatus { //periksa semua kemungkinan cara untuk menang, dapatkan {}
    get{
      if let check = self.checkIndexes([0, 1, 2]) {
        return check
      } else if let check = self.checkIndexes([3, 4, 5]) {
        return check
      } else if let check = self.checkIndexes([6, 7, 8]) {
        return check
      } else if let check = self.checkIndexes([0, 3, 6]) {
        return check
      } else if let check = self.checkIndexes([1, 4, 7]) {
        return check
      } else if let check = self.checkIndexes([2, 5, 8]) {
        return check
      } else if let check = self.checkIndexes([0, 4, 8]) {
        return check
      } else if let check = self.checkIndexes([2, 4, 6]) {
        return check
      }
      return .empty
    }
  }
  
  private func checkIndexes(_ indexes: [Int]) -> SquareStatus? {
    var homeCounter:Int = 0
    var visitorCounter:Int = 0
    for anIndex in indexes {
      let aSquare = squares[anIndex]
      if aSquare.status == .home {
        homeCounter = homeCounter + 1
      } else if aSquare.status == .visitor {
        visitorCounter = visitorCounter + 1
      }
    }
    if homeCounter == 3 {
      return .home
    } else if visitorCounter == 3 {
      return .visitor
    }
    return nil
  }
  
  private func aiMOve() {
    var anIndex = Int.random(in: 0...8)
    while (makeMove(index: anIndex, player: .visitor) == false  && gameOver.1 == false) {
      anIndex = Int.random(in: 0...8)
    }
  }
  
  func makeMove(index: Int, player: SquareStatus) -> Bool {
    if squares[index].status == .empty { //jika ada di x atau o dalam bujur sangkar
      var square = squares[index] //dapatkan indeks persegi
      square.status = player // atur status persegi ke pemain
      squares[index] = square // indeks kotak array ditetapkan ke persegi
      if player == .home {aiMOve()} //membuat AI bergerak saat pemain telah memutuskan
      return true
    }
    return false
  }
}

struct SquareView: View { //buat tombol persegi
  var dataSource : Square
  var action : () -> Void
  var body : some View {
    Button(action: {print(self.dataSource.status)
      self.action()
    }) {
      Text((dataSource.status != .empty) ? (dataSource.status != .visitor) ? "X" : "O" : " ")
        .font(.largeTitle)
        .foregroundColor(Color.black)
        .frame(minWidth: 80, minHeight: 80)
        .background(Color.blue)
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
    }
  }
}

struct MainBoard: View {
  @ObservedObject var checker = ModelBoard()
  @State private var isGameOver = false
  
  func buttonAction(_ index: Int) {
    _ = self.checker.makeMove(index: index, player: .home)
    self.isGameOver = self.checker.gameOver.1 //memberikan nilai yang dikembalikan, yaitu bool
  }
  
  var body: some View {
    VStack{
      HStack{
        SquareView(dataSource: checker.squares[0]) { self.buttonAction(0)} //1st kotak
        SquareView(dataSource: checker.squares[1]) { self.buttonAction(1)} //2nd kotak
        SquareView(dataSource: checker.squares[2]) { self.buttonAction(2)} //3rd kotak
      }
      
      HStack{
        SquareView(dataSource: checker.squares[3]) { self.buttonAction(3)} //4th kotak
        SquareView(dataSource: checker.squares[4]) { self.buttonAction(4)} //5th kotak
        SquareView(dataSource: checker.squares[5]) { self.buttonAction(5)} //6th kotak
      }
      
      HStack{
        SquareView(dataSource: checker.squares[6]) { self.buttonAction(6)} //7th kotak
        SquareView(dataSource: checker.squares[7]) { self.buttonAction(7)} //8th kotak
        SquareView(dataSource: checker.squares[8]) { self.buttonAction(8)} //9th kotak
      }
    }
    .alert(isPresented: $isGameOver) {
      Alert(title: Text("Game Over"),
            message: Text(self.checker.gameOver.0 != .empty ?
                            (self.checker.gameOver.0 == .home) ? "You Win!" : "You Lose!"
                          : "Draw"), dismissButton: Alert.Button.destructive(Text("Ok"), action: {self.checker.resetGame()
                          }) )
    }
  }
}

struct TitleView: View {
  var body: some View {
    Text("Tic Tac Toe Game")
      .font(.largeTitle) .bold()
      .fontWeight(.light)
  }
}


struct ContentView: View {
  var body: some View {
    MainBoard()
    TitleView()
  }
}
