# Swift Bindings

Implementing Swift variables and computed properties in an observable fashion.

## Getting Started

Code example, combining `Variable`s:

```swift
let names = Variable<[String]>(["Alice", "Bob"])
let nameLengthFilter = Variable<Int>(5)

let namesWithFilteredLength =
    Computation<[String]>.combining(names, nameLengthFilter) { (names, length) -> [String] in
        return names.filter { $0.count == length }
    }

print(names.value) // ["Alice", "Bob"]
print(nameLengthFilter.value) // 5
print(namesWithFilteredLength.value) // ["Alice"]
nameLengthFilter.set(3)
print(namesWithFilteredLength.value) // ["Bob"]
nameLengthFilter.set(10)
print(namesWithFilteredLength.value) // []
```

Code example, listening to `Bindable`s:

```swift
let names = Variable<[String]>(["Alice", "Bob"])
let nameLengthFilter = Variable<Int>(5)

let namesWithFilteredLength =
    Computation<[String]>.combining(names, nameLengthFilter) { (names, length) -> [String] in
        return names.filter { $0.count == length }
    }

// will print "["Alice", "Bob"]"
var binding: Binding? = namesWithFilteredLength.bind { (filteredNames) in
    print(filteredNames)
}

// will print "["Bob"]"
nameLengthFilter.set(3)
// will print "[]"
nameLengthFilter.set(10)

// deallocate binding to stop listening to changes
binding = nil
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
