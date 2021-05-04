# JsArray2Ex

A ReScript library that extends Js.Array2 module.

## Installation

`yarn add rescript-js-array2-ex` <br>
or <br>
`npm install rescript-js-array2-ex`

## Getting started
`JsArray2Ex` extends `Js.Array2` module. `open JsArray2Ex` will opens `Js.Array2` module too.
```rescript
open JsArray2Ex
let nums = [1, 2, 3, 4, 5, 6, 7]
let chunks = nums->chunkBySize(nums->length/2)
Js.log(chunks)
```

## APIs
### t
```rescript
type t<'a> = array<'a>
```

### create: `int => t<'a>`
```rescript
let intNums:t<int> = create(10)
let floatNums:t<float> = create(10)
let strings:t<string> = create(10)
```

### chunkBySize: `(t<'a>, int) => t<t<'a>>`
```rescript
[1, 2, 3, 4, 5, 6, 7]->chunkBySize(4)

// result => [[1, 2, 3, 4], [5, 6, 7]]
```
> throws `JsArray2Ex.Invalid_argument` if chunkSize argument is not positive.

### countBy: `(t<'a>, 'a => 'key) => t<('key, int)>`
```rescript
[1, 1, 2, 2, 1, 3, 2]->countBy(x => mod(x, 2) == 0)

// result => [(false, 4), (true, 3)]
```


### scan: `(t<'a>, ('b, 'a) => 'b, 'b) => t<'b>`
```rescript
[1, 2, 3]->scan((x, y) => x + y, 0)

// result => [0, 1, 3, 6]
```

### scanRight: `(t<'a>, ('a, 'b) => 'b, 'b) => t<'b>`
```rescript
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]->scanRight((x, y) => x + y, 0) 
      
// result => [55, 54, 52, 49, 45, 40, 34, 27, 19, 10, 0]
```

### unfold: `('a => option<('b, 'a)>, 'a) => t<'b>`
```rescript
let fib = n => unfold(((x, (a, b))) => x < n ? Some(a + b, (x + 1, (b, a + b))) : None, (0, (0, 1)))
let fibs = fib(10)

// result => [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
```

### mapFold : `(t<'a>, ('b, 'a) => ('c, 'b), 'b) => (t<'c>, 'b)`
```rescript
let arr1To10 = Belt.Array.makeBy(10, x => x + 1)
let result = arr1To10->mapFold((x, y) => (x + y, x + y), 0)

// result => ([1, 3, 6, 10, 15, 21, 28, 36, 45, 55], 55)
```

### mapFoldRight: `(t<'a>, ('a, 'b) => ('c, 'b), 'b) => (t<'c>, 'b)`
```rescript
let arr1To10 = Belt.Array.makeBy(10, x => x + 1)
let result = arr1To10->mapFoldRight((x, y) => (x + y, x + y), 0)

// result => ([55, 54, 52, 49, 45, 40, 34, 27, 19, 10], 55)
```

### <br>Author

Nyi Nyi Than
- LinkedIn: [@nyinyithann](https://www.linkedin.com/in/nyinyithan/)
- Twitter: [@JazzTuyat](https://twitter.com/JazzTuyat)

### License

MIT