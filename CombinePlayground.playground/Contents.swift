import Foundation
import Combine

var cancellables = Set<AnyCancellable>()

// MARK: - Publisher sequence
demo(of: "Publisher") {
    let numberPulbisher = [9, 3, 2, 18, 3, 3, 11, 39].publisher
    numberPulbisher
        .print("publisher")
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "Publisher with object") {
    struct Person {
        let name: String
        let income: Int
    }
    let peoplePublisher = [
                            Person(name: "Jake", income: 10),
                            Person(name: "Tom", income: 20)
                          ].publisher
    peoplePublisher
        .print("publisher")
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

// MARK: - Publisher creators
demo(of: "Just") {
    let publisher1 = Just(1)
    publisher1
        .print("Just")
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

// MARK: - Subscriber
demo(of: "Subscriber") {
    let publisher = [1, 2, 3].publisher
    publisher.sink { event in
        print(event)
    }
    .store(in: &cancellables)
}

demo(of: "Error event") {
    enum MyError: Error {
        case anError
    }

    let subject = PassthroughSubject<Int, MyError>()
    subject.sink { completion in
        print("Received completion (sink)", completion)
    } receiveValue: { value in
        print("Received value (sink)", value)
    }
    .store(in: &cancellables)

    subject.send(1)
    subject.send(2)
    subject.send(completion: .failure(MyError.anError))
    subject.send(3)
}

demo(of: "Completed event") {
    let subject = PassthroughSubject<Int, Never>()
    subject.sink { completion in
        print("Received completion (sink)", completion)
    } receiveValue: { value in
        print("Received value (sink)", value)
    }
    .store(in: &cancellables)

    subject.send(1)
    subject.send(completion: .finished)
    subject.send(2)
    subject.send(3)
}

demo(of: "Empty") {
    let empty = Empty<Int, Never>() // completeImmediately: true
    empty.sink { completion in
        print("Received completion (sink)", completion)
    } receiveValue: { value in
        print("Received value (sink)", value)
    }
    .store(in: &cancellables)
    
    empty.replaceEmpty(with: 1)
        .sink { completion in
            print("Received completion (sink)", completion)
        } receiveValue: { value in
            print("Received value (sink)", value)
        }.store(in: &cancellables)
}

demo(of: "Never") {
    let empty = Empty<Int, Never>(completeImmediately: false)
    empty.sink { completion in
        print("Received completion (sink)", completion)
    } receiveValue: { value in
        print("Received value (sink)", value)
    }
    .store(in: &cancellables)
    
    empty.replaceEmpty(with: 1)
        .sink { completion in
            print("Received completion (sink)", completion)
        } receiveValue: { value in
            print("Received value (sink)", value)
        }.store(in: &cancellables)
}

// MARK: - Cancellable
demo(of: "Cancellable") {
    let cancellable = [1, 2, 3].publisher.sink { event in
        print(event)
    }
    cancellable.cancel()
}

demo(of: "Cancellable with delay") {
    let cancellable = [1, 2, 3].publisher.delay(for: .seconds(2.0), scheduler: DispatchQueue.main).sink { event in
        print(event)
    }
    cancellable.cancel()
}

// MARK: - Subject
demo(of: "PassthroughSubject") {
    let passthroughSubject = PassthroughSubject<Int, Never>()
    passthroughSubject.send(1)

    let subscriber1 = passthroughSubject.sink {
        print("subscriber1: \($0)")
    }
    subscriber1.store(in: &cancellables)

    passthroughSubject.send(2)

    let subscriber2 = passthroughSubject.sink {
        print("subscriber2: \($0)")
    }
    subscriber2.store(in: &cancellables)

    passthroughSubject.send(3)
    passthroughSubject.send(completion: .finished)
    passthroughSubject.send(4)
}

demo(of: "CurrentValueSubject") {
    let currentValueSubject = CurrentValueSubject<Int, Never>(1)

    let subscriber1 = currentValueSubject.sink {
        print("subscriber1: \($0)")
    }
    subscriber1.store(in: &cancellables)

    currentValueSubject.send(2)

    let subscriber2 = currentValueSubject.sink {
        print("subscriber2: \($0)")
    }
    subscriber2.store(in: &cancellables)

    currentValueSubject.send(3)
    currentValueSubject.send(completion: .finished)
    currentValueSubject.send(4)
}

// MARK: - Operator
demo(of: "filter") {
    [2, 23, 5, 60, 1, 31].publisher
        .filter { $0 > 10 }
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "removeDuplicates") {
    [1, 1, 2, 2, 1].publisher
        .removeDuplicates()
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "map") {
    [1, 2].publisher
        .map { "String: " + String($0) }
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "compactMap") {
    ["1", "not-a-number", "2"].publisher
        .compactMap { Int($0) }
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "flatMap") {
    struct TemperatureSensor {
        let temperature: AnyPublisher<Int, Never>
    }

    let sensor1 = TemperatureSensor(temperature: [21, 23].publisher.eraseToAnyPublisher())
    let sensor2 = TemperatureSensor(temperature: [22, 25].publisher.eraseToAnyPublisher())

    [sensor1, sensor2].publisher
        .flatMap { $0.temperature }
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "prepend") {
    [1, 2].publisher
        .prepend(3, 4)
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "append") {
    [1, 2].publisher.append([3, 4].publisher)
        .sink {
            print($0)
        }
        .store(in: &cancellables)
}

demo(of: "merge") {
    let firstSubject = PassthroughSubject<Int, Never>()
    let secondSubject = PassthroughSubject<Int, Never>()

    firstSubject.merge(with: secondSubject)
        .sink {
            print($0)
        }
        .store(in: &cancellables)

    firstSubject.send(1)
    firstSubject.send(2)
    secondSubject.send(11)
    firstSubject.send(3)
    secondSubject.send(12)
    secondSubject.send(13)
    firstSubject.send(4)
}

demo(of: "combineLatest") {
    let firstSubject = PassthroughSubject<String, Never>()
    let secondSubject = PassthroughSubject<String, Never>()

    firstSubject.combineLatest(secondSubject)
        .sink {
            print("\($0) - \($1)")
        }
        .store(in: &cancellables)

    firstSubject.send("1")
    secondSubject.send("a")
    firstSubject.send("2")
    secondSubject.send("b")
    secondSubject.send("c")
    firstSubject.send("3")
    firstSubject.send("4")
}

demo(of: "zip") {
    let firstSubject = PassthroughSubject<String, Never>()
    let secondSubject = PassthroughSubject<String, Never>()

    firstSubject.zip(secondSubject)
        .sink {
            print("\($0) - \($1)")
        }
        .store(in: &cancellables)

    firstSubject.send("1")
    secondSubject.send("a")
    firstSubject.send("2")
    secondSubject.send("b")
    secondSubject.send("c")
    firstSubject.send("3")
    firstSubject.send("4")
}

// MARK: - Scheduler
demo(of: "Scheduler") {
    [1, 2, 3, 4].publisher
        .print()
        .subscribe(on: DispatchQueue.global())
        .handleEvents(receiveOutput:  { print("\(getThreadName()): \($0)") })
        .receive(on: DispatchQueue.main)
        .sink { print("\(getThreadName()): \($0)") }
        .store(in: &cancellables)
}
