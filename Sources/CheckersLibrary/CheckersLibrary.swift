extension UInt64 {
    subscript(index: Int) -> Bool {
        get {
            return self&(1<<index) > 0
        }
        set(newValue) {
            if newValue {
                self = self | (1<<index)
            } else {
                self = self & (~(1<<index))
            }
        }
    }
}

/*struct CheckersLibrary {
    var text = "Hello, World!"
}*/
