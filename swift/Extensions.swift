// Playground - noun: a place where people can play

import UIKit

/**
 * extension
 */

// 연산속성(computed property) 확장 예제
extension Double {
    var km: Double { return self * 1_000.0 } // read-only computed property
    var m: Double { return self }
    var cm:Double { return self / 100.0 }
    var mm: Double { return self / 1_000.0 }
    var ft: Double { return self / 3.28084 }
}

let oneInch = 25.4.mm
println("One inch is \(oneInch) meters")

struct Size {
    var width = 0.0, height = 0.0
}

struct Point {
    var x = 0.0, y = 0.0
}

struct Rect {
    var origin = Point()
    var size = Size()
}

let defaultRect = Rect()
let memberwiseRect = Rect(origin: Point(x: 2.0, y: 2.0), size: Size(width: 5.0, height: 5.0)) // default initializer

// 이니셜라이저 확장 예제
extension Rect {
    init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: Point(x: originX, y: originY), size: size)
    }
}

let centerRect = Rect(center: Point(x:4.0, y:4.0), size: Size(width: 3.0, height: 3.0))

// 메소드 확장 예제
extension Int {
    func repetitions(task: () -> ()) {
        for i in 1...self {
            task()
        }
    }
}
3.repetitions({ println("Hello") })
3.repetitions { println("Goodbye !") }

// Mutating 메소드 확장 예제
extension Int {
    mutating func square() { // self를 변경하기 위해 mutating을 사용
        self = self * self
    }
}
var someInt = 3
someInt.square()
someInt

// subscript 확장 예제
extension Int {
    subscript(var digitIndex: Int) -> Int {
        var decimalBase = 1
            while digitIndex > 0 {
                decimalBase *= 10
                --digitIndex
            }
            return (self / decimalBase) % 10
    }
}
746381295[0]
746381295[1]
746381295[2]
746381295[3]

// Nested Types 확장 예제
extension Character {
    enum Kind {
        case Vowel, Consonant, Other
    }
    var kind: Kind { // computed property
        switch String(self).lowercaseString {
            case "a", "e", "i", "o", "u":
                return .Vowel
            case "b", "c", "d", "f", "g", "h", "j", "k", "l", "m",
                "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z":
                return .Consonant
            default:
                return .Other
        }
    }
}

func printLetterKinds(word: String) {
    println("\(word)' is made up of the following kinds of letters:")
    for character in word {
        switch character.kind {
        case .Vowel:
            print("vowel ")
        case .Consonant:
            print("consonant ")
        case .Other:
            print("other ")
        }
    }
    print("\n")
}
printLetterKinds("Hello")
