/**
 * protocol
 */

// protocol syntax
protocol SomeProtocol {
    // 요구사항을 적는다
}
protocol AnotherProtocol {
    // 요구사항을 적는다
}
struct SomeStructure:SomeProtocol, AnotherProtocol {
    // 프로토콜의 요구사항에 맞게 구현한다
}
class SomeClass:SomeProtocol, AnotherProtocol {
    // 프로토콜의 요구사항에 맞게 구현
}
enum SomeEnum:SomeProtocol, AnotherProtocol {
    // enum도 요구사항만 맞추면 프로토콜 사용이 가능하다?
}

// protocol 예제 1
protocol FullyNamed {
    var fullName: String { get } // 읽기/쓰기 속성은 { get set }
}

struct Person: FullyNamed {
    var fullName: String
}
/*
enum EnumPerson: FullyNamed {
    var fullName: String {
        get { return "ABC" }
        set { newValue }
    }
}*/

var john = Person(fullName: "John")
john.fullName
john.fullName = "James" // 프로토콜 요구사항 get과는 무관하게 쓰기 가능

// protocol 예제 2
class Starship: FullyNamed {
    var prefix: String?
    var name: String
    init(name: String, prefix: String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    var fullName: String {
        get {
            return prefix! + name
        }
        set { // 프로토콜 요구사항이 get set이라면 set도 반드시
            newValue
        }
    }
}

var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
ncc1701.fullName

// 메소드 요구사항 예제
protocol RandomNumberGenerator {
    func random() -> Double // 메소드 내용은 정의하지 않는다
}

class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 4.20
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double { // 메소드 구현
        lastRandom = ((lastRandom * a + c) % m)
        return lastRandom / m
    }
}
let generator = LinearCongruentialGenerator()
println("Here's a random number: \(generator.random())")
println("And another one: \(generator.random())")

// 변이(mutating) 메소드
protocol Togglable {
    mutating func toggle()
}
enum OnOffSwitch: Togglable {
    case Off, On
    mutating func toggle() {
        switch self {
        case Off:
            self = On
        case On:
            self = Off
        }
    }
}
var lightSwitch = OnOffSwitch.Off
lightSwitch.toggle()

// 타입으로서의 프로토콜
class Dice {
    let sides: Int
    let generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}
var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
for _ in 1...5 {
    println("Random dice value \(d6.roll())")
}

// 위임(Delegation)
protocol DiceGame {
    var dice: Dice { get }
    func play()
}
protocol DiceGameDelegate {
    func gameDidStart(game: DiceGame)
    // didStartNewTurnWithDiceRoll은 external paramter name
    func game(game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int)
    func gameDidEnd(game: DiceGame)
}

class SnakeAndLadders: DiceGame {
    let finalSquare = 25
    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board: [Int]
    init() {
        board = [Int](count: finalSquare + 1, repeatedValue: 0)
        board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
        board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
    }
    var delegate: DiceGameDelegate?
    func play() {
        square = 0
        delegate?.gameDidStart(self) // delegate가 없을 경우 optional chaining(?)으로 인해 걍 넘어감
        gameLoop: while square != finalSquare {
            let diceRoll = dice.roll()
            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll) // options chaining
            switch square + diceRoll {
            case finalSquare:
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                continue gameLoop
            default:
                square += diceRoll
                square += board[square]
            }
        }
        delegate?.gameDidEnd(self) // optional chaining
    }
}

class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    func gameDidStart(game: DiceGame) {
        numberOfTurns = 0
        if game is SnakeAndLadders {
            println("Snakes and Ladders New Game is getting started.")
        }
        println("The game will use a \(game.dice.sides) sides dice")
    }
    func game(game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
        ++numberOfTurns
        println("Dice is \(diceRoll)")
    }
    func gameDidEnd(game: DiceGame) {
        println("The game used \(numberOfTurns) turns.")
    }
}
let tracker = DiceGameTracker()
let game = SnakeAndLadders()
game.delegate = tracker
game.play()


// 확장을 프로토콜 일치에 추가
protocol TextRepresentable {
    func asText() -> String
}

extension Dice: TextRepresentable {
    func asText() -> String {
        return "\(sides)면체 주사위"
    }
}

let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
println(d12.asText())

extension SnakeAndLadders: TextRepresentable {
    func asText() -> String {
        return "뱀과 사다리 게임은\(finalSquare)칸"
    }
}
println(game.asText())

// 확장과 동시에 프로토콜 적용 선언
struct Hamster {
    var name: String
    func asText() -> String {
        return "햄스터 이름은 \(name)"
    }
}
extension Hamster: TextRepresentable { }

let simonTheHamster = Hamster(name: "Simon")
let somethingTextRepresentable: TextRepresentable = simonTheHamster
println(somethingTextRepresentable.asText())

// 프로토콜 타입의 콜렉션(Collection)들
let things: [TextRepresentable] = [game, d12, simonTheHamster]
for thing in things {
    println(thing.asText())
}

// 프로토콜 상속
protocol PrettyTextRepresentable: TextRepresentable {
    func asPrettyText() -> String
}

extension SnakeAndLadders: PrettyTextRepresentable {
    func asPrettyText() -> String {
        var output = asText() + ":\n"
        for index in 1...finalSquare {
            switch board[index] {
            case let ladder where ladder > 0:
                output += "∧ "
            case let snake where snake < 0:
                output += "∨ "
            default:
                output += "O "
            }
        }
        return output
    }
}
println(game.asPrettyText())

// 프로토콜 합성
protocol Named {
    var name: String { get }
}
protocol Aged {
    var age: Int { get }
}
struct Person2: Named, Aged {
    var name: String
    var age: Int
}
func wishHappyBirthday(celebrator: protocol<Named, Aged>) { // protocol<xxx,xxx> 형식
    println("\(celebrator.name)의 \(celebrator.age)번째 생일을 축하합니다.")
}
let birthdayPerson = Person2(name: "Malcom", age: 21)
wishHappyBirthday(birthdayPerson) // protocol<Named, Aged> 타입으로 넘겨줌

// 프로토콜 일치를 확인하기
// is : 인스턴스가 프로토콜과 일치하면 true, 아니면 false
// as : 다운캐스팅하고 실패하면 런타임 오류
// as? : 다운캐스팅하고 일치하지 않으면 nil
// @objc : 프로토콜 일치확인을 위하여 꼭 써줘야 한다(안해주면 downcast 오류남)
@objc protocol HasArea {
    var area: Double { get }
}
class Circle: HasArea {
    let pi = 3.1415927
    var radius: Double
    var area: Double { return pi * radius * radius }
    init(radius: Double) { self.radius = radius }
}
class Country: HasArea {
    var area: Double
    init(area: Double) { self.area = area }
}

class Animal {
    var legs: Int
    init(legs: Int) { self.legs = legs }
}

let objects: [AnyObject] = [
    Circle(radius: 2.0),
    Country(area: 243_610),
    Animal(legs: 4)
]
for object in objects {
    //println(object is HasArea)
    if let objectWithArea = object as? HasArea {
        println("넓이는 \(objectWithArea.area)")
    } else {
        println("넓이는 가지고 있지 않다")
    }
}

// 프로토콜 선택적 요구사항
@objc protocol CounterDataSource { // @objc 붙여줘야함
    optional func incrementForCount(count: Int) -> Int // optional 키워드 사용
    optional var fixedIncrement: Int { get }
}
@objc class Counter {
    var count = 0
    var dataSource: CounterDataSource?
    func increment() {
        if let amount = dataSource?.incrementForCount?(count) {
            count += amount
        } else if let amount = dataSource?.fixedIncrement? {
            count += amount // fixedIncrement만큼 증가
        }
    }
}

class ThreeSource: CounterDataSource {
    let fixedIncrement = 3
}

var counter = Counter()
counter.dataSource = ThreeSource()
for _ in 1...4 {
    counter.increment()
    println(counter.count)
}

class TowardsZeroSource: CounterDataSource {
    // count값이 0보다 작든 크든 0을 향해 카운팅
    func incrementForCount(count: Int) -> Int {
        if count == 0 {
            return 0
        } else if count < 0 {
            return 1
        } else {
            return -1
        }
    }
}

counter.count = -4
counter.dataSource = TowardsZeroSource()
for _ in 1...5 {
    counter.increment()
    println(counter.count)
}
