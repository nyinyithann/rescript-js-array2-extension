# JsArray2Ex

A ReScript library that extends Js.Array2 module.

## Installation

`yarn add js-array2-ex` <br>
or <br>
`npm install js-array2-ex`

Add it to `bsconfig.json`
  ```json
  "bs-dependencies": ["js-array2-ex"]
  ```


## Getting started
`JsArray2Ex` extends `Js.Array2` module. `open JsArray2Ex` will opens `Js.Array2` module too.
```rescript
open JsArray2Ex

let fib = n => unfold(((x, (a, b))) => x < n ? Some(a + b, (x + 1, (b, a + b))) : None, (0, (0, 1)))
fib(10)
->pairwise
->windowed(4)
->groupBy(x =>
  x->averageIntBy(y =>
    switch y {
    | (f, _) => f
    }
  )
)
->forEach(x => {
  let (f, s) = x
  Js.log(j`Average:$f by the first value of pairs`)
  Js.log(s)
})

// result =>
Average:2.75 by the first value of pairs
[ [ [ 1, 2 ], [ 2, 3 ], [ 3, 5 ], [ 5, 8 ] ] ]
Average:4.5 by the first value of pairs
[ [ [ 2, 3 ], [ 3, 5 ], [ 5, 8 ], [ 8, 13 ] ] ]
Average:7.25 by the first value of pairs
[ [ [ 3, 5 ], [ 5, 8 ], [ 8, 13 ], [ 13, 21 ] ] ]
Average:11.75 by the first value of pairs
[ [ [ 5, 8 ], [ 8, 13 ], [ 13, 21 ], [ 21, 34 ] ] ]
Average:19 by the first value of pairs
[ [ [ 8, 13 ], [ 13, 21 ], [ 21, 34 ], [ 34, 55 ] ] ]
Average:30.75 by the first value of pairs
[ [ [ 13, 21 ], [ 21, 34 ], [ 34, 55 ], [ 55, 89 ] ] ]
```

## APIs
#### `t`
```rescript
type t<'a> = array<'a>
```

#### `create: int => t<'a>`
```rescript
let intNums:t<int> = create(10)
let floatNums:t<float> = create(10)
let strings:t<string> = create(10)
```

#### `chunkBySize: (t<'a>, int) => t<t<'a>>`
```rescript
let result = [1, 2, 3, 4, 5, 6, 7] -> chunkBySize(4)

// result => [[1, 2, 3, 4], [5, 6, 7]]
```
> throws `JsArray2Ex.Invalid_argument` if chunkSize argument is not positive.

#### `countBy: (t<'a>, 'a => 'key) => t<('key, int)>`
```rescript
let result = [1, 1, 2, 2, 1, 3, 2] -> countBy(x => mod(x, 2) == 0)

// result => [(false, 4), (true, 3)]
```


#### `scan: (t<'a>, ('b, 'a) => 'b, 'b) => t<'b>`
```rescript
let result = [1, 2, 3] -> scan((x, y) => x + y, 0)

// result => [0, 1, 3, 6]
```

#### `scanRight: (t<'a>, ('a, 'b) => 'b, 'b) => t<'b>`
```rescript
let result = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] -> scanRight((x, y) => x + y, 0) 
      
// result => [55, 54, 52, 49, 45, 40, 34, 27, 19, 10, 0]
```

#### `unfold: ('a => option<('b, 'a)>, 'a) => t<'b>`
```rescript
let fib = n => unfold(((x, (a, b))) => x < n ? Some(a + b, (x + 1, (b, a + b))) : None, (0, (0, 1)))
let result = fib(10)

// result => [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
```

#### `mapFold : (t<'a>, ('b, 'a) => ('c, 'b), 'b) => (t<'c>, 'b)`
```rescript
let arr1To10 = Belt.Array.makeBy(10, x => x + 1)
let result = arr1To10 -> mapFold((x, y) => (x + y, x + y), 0)

// result => ([1, 3, 6, 10, 15, 21, 28, 36, 45, 55], 55)
```

#### `mapFoldRight: (t<'a>, ('a, 'b) => ('c, 'b), 'b) => (t<'c>, 'b)`
```rescript
let arr1To10 = Belt.Array.makeBy(10, x => x + 1)
let result = arr1To10 -> mapFoldRight((x, y) => (x + y, x + y), 0)

// result => ([55, 54, 52, 49, 45, 40, 34, 27, 19, 10], 55)
```

#### `distinct: t<'a> => t<'a>`
```rescript
let result = 
[{"name": "Jack", "age": 10.4},
 {"name": "Jack", "age": 10.4},
 {"name": "Bliss", "age": 10.2}] -> distinct

// result => [{"name": "Jack", "age": 10.4}, {"name": "Bliss", "age": 10.2}]
```

#### `distinctBy: (t<'a>, 'a => 'b) => t<'a>`
```rescript
let result = [{name: "a", age: 10.4}, {name: "b", age: 10.4}, {name: "c", age: 10.4}] -> distinctBy(x => x.age)

// result => [{name: "a", age: 10.4}]      
```

#### `groupBy: (t<'a>, 'a => 'b) => t<('b, t<'a>)>`
```rescript
let result = [1, 2, 3, 4, 5, 6] -> groupBy(x => mod(x, 2) == 0)

// result => [(false, [1, 3, 5]), (true, [2, 4, 6])]
```

#### `skip: (t<'a>, int) => t<'a>`
```rescript
let result = [1, 2, 3, 4, 5] -> skip(2)

// result => [3, 4, 5]
```

#### `skipWhile: (t<'a>, 'a => bool) => t<'a>`
```rescript
let result = [1, 2, 3, 4] -> skipWhile(x => x < 3)

// result => [3, 4]
```

#### `take: (t<'a>, int) => t<'a>`
```rescript
let result = [1, 2, 3] -> take(2) 

// result => [1, 2]
```
#### `takeWhile: (t<'a>, 'a => bool) => t<'a>`
```rescript
let result = [1,2,3,4,5,6] -> takeWhile(x => x < 2)

// result => [1]
```

#### `splitAt: (t<'a>, int) => (t<'a>, t<'a>)`
```rescript
let result = [1, 2, 3, 4, 5] -> splitAt(3)

// result => ([1, 2, 3], [4, 5])
```

> throws `JsArray2Ex.Invalid_operation` if the source array has insufficient number of elements.

#### `transpose: t<t<'a>> => t<t<'a>>`

```rescript
let result = [[1, 2], [4, 5]] -> transpose  

// result => [[1, 4], [2, 5]]                                       
```
>  throws `JsArray2Ex.Invalid_argument` if the lengths of the elements of the input array is not the same.

#### `windowed: (t<'a>, int) => t<t<'a>>`

```rescript
let result = [1,2,3,4,5] -> windowed(2) 

// result =>  [[1,2], [2,3], [3,4],[4,5]]
```

> throws `JsArray2Ex.Invalid_argument` if the size argument is less than or equal to zero.

#### `except: (t<'a>, t<'a>) => t<'a>`

```rescript
let result = [1, 2, 3] -> except([1, 2])

// result => [3]
```

#### `head: t<'a> => 'a`
```resscript
let result = [1,2,3] -> head

// result => 1
```

> throws `JsArray2Ex.Invalid_argument` if the source array is empty

#### `tryHead: t<'a> => option<'a>`

```rescript
let result = [1,2,3] -> tryHead

// result => Some(1)
```

#### `tail: t<'a> => t<'a>`
```rescript
let result = [1,2,3] -> tail

// result => [2, 3] 
```

#### `map2: (t<'a>, t<'b>, ('a, 'b) => 'c) => t<'c>`
```rescript
let result = map2([1, 2, 3], [4, 5, 6], (x, y) => x + y)

// result => [5, 7, 9]
```

> throws `JsArray2Ex.Invalid_argument` if the lengths of the input arrays are not the same.

#### `map3: (t<'a>, t<'b>, t<'c>, ('a, 'b, 'c) => 'd) => t<'d>`

```rescript
let result = map3([1, 2, 3], [4, 5, 6], [7,8,9], (x, y, z) => x + y + z)

// result => [12, 15, 18]
```

> throws `JsArray2Ex.Invalid_argument` if the lengths of the input arrays are not the same.

#### `pairwise: t<'a> => t<('a, 'a)>`

```rescript
let result = [1, 2, 3, 4] -> pairwise

// result => [(1, 2), (2, 3), (3, 4)]
```

#### `minInt: t<int> => int`
```rescript
let result = [1,2,3] -> minInt 

// result => 1
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `maxInt: t<int> => int`

```rescript
let result = [1,2,3] -> maxInt

// result => 3
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `minFloat: t<float> => float`

```rescript
let result = [1., 2., 3.] -> minFloat

// result => 1.
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `maxFloat: t<float> => float`

```rescript
let result = [1., 2., 3.] -> maxFloat

// result => 3.
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `sumInt: t<int> => int`

```rescript
let result = [1, 2, 3] -> sumInt

// result => 6
```

#### `sumFloat: t<float> => float`
```rescript
let result = [1., 2., 3.] -> sumFloat

// result => 6.
```

#### `averageInt: t<int> => float`
```rescript
let result = [1, 2, 3] -> averageInt

// result => 2.
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `averageFloat: t<float> => float`

```rescript
let result = [1., 2., 3.] -> averageFloat

// result => 2.
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `sumIntBy: (t<'a>, 'a => int) => int`

```rescript
let result = [1, 2, 3, 4] -> sumIntBy(x => x > 2 ? x : 0)

// result => 7
```

#### `sumFloatBy: (t<'a>, 'a => float) => float`
```rescript
let result = [1, 2, 3, 4] -> sumFloatBy(x => x > 2 ? Js.Int.toFloat(x) : 0.)

// result => 7.
```

#### `minBy: (t<'a>, 'a => 'b) => 'a`
```rescript
let people = [{"name": "abc", "age": 10.}, {"name": "def", "age": 20.}]
let result =   people->minBy(x => x["age"])

// result => {"name": "abc", "age": 10.}  
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `maxBy: (t<'a>, 'a => 'b) => 'a`

```rescript
let people = [{"name": "abc", "age": 10.}, {"name": "def", "age": 20.}]
let result =   people->maxBy(x => x["age"])

// result => {"name": "def", "age": 20.}  
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `averageIntBy: (t<'a>, 'a => int) => float`

```rescript
let result = [1, 2, 3, 4, 5]->averageIntBy(x => x > 2 ? x : 0)

// result => 2.4
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

#### `averageFloatBy: (t<'a>, 'a => float) => float`

```rescript
let result = [1., 2., 3., 4., 5.]->averageFloatBy(x => x > 2. ? x : 0.)

// result => 2.4
```

> throws `JsArray2Ex.Invalid_argument` if the input array is empty.

### <br>Author


Nyi Nyi Than (Jazz)
- LinkedIn: [@nyinyithann](https://www.linkedin.com/in/nyinyithan/)
- Twitter: [@JazzTuyat](https://twitter.com/JazzTuyat)

### License

MIT