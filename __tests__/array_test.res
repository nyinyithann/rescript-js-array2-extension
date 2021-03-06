open Jest
open ExpectJs
open JsArray2Ex

//#region type
type person = {name: string, age: float}

type shape =
  | Rectangle({width: float, height: float})
  | Circle({radius: float})
  | Prism({width: (float, float), height: float})

@unboxed type rec any = Any('a): any

type lang = {name: string, family: {"name": string}}
//#endregion

//#region chunkBySize
describe("chunkBySize", () => {
  let arr = [1, 2, 3, 4, 5, 6, 7]

  test("should return an empty array if the source is empty", () =>
    expect([]->chunkBySize(2) == [])->toBeTruthy
  )

  test("should throw exception if chunkSize is not positive, chunkSize = -1", () => {
    expect(() => chunkBySize(arr, -1))->toThrow
  })

  test("should throw exception if chunkSize is not positive, chunkSize = 0", () => {
    expect(() => chunkBySize(arr, 0))->toThrow
  })

  test("should return correct answer", () => {
    expect(arr->chunkBySize(1) == [[1], [2], [3], [4], [5], [6], [7]])->toBeTruthy
  })

  test("should return correct answer", () =>
    expect(arr->chunkBySize(2) == [[1, 2], [3, 4], [5, 6], [7]])->toBeTruthy
  )

  test("should return correct answer", () => {
    expect(arr->chunkBySize(3) == [[1, 2, 3], [4, 5, 6], [7]])->toBeTruthy
  })

  test("should return correct answer", () => {
    expect(arr->chunkBySize(4) == [[1, 2, 3, 4], [5, 6, 7]])->toBeTruthy
  })

  test("should return correct answer", () => {
    expect(arr->chunkBySize(5) == [[1, 2, 3, 4, 5], [6, 7]])->toBeTruthy
  })

  test("should return correct answer", () => {
    expect(arr->chunkBySize(6) == [[1, 2, 3, 4, 5, 6], [7]])->toBeTruthy
  })

  test("should return correct answer", () => {
    expect(arr->chunkBySize(length(arr)) == [arr])->toBeTruthy
  })

  test(
    "should return an array containing the source if chunkSize is greater than the length of the source",
    () => expect(arr->chunkBySize(length(arr) + 1) == [[1, 2, 3, 4, 5, 6, 7]])->toBeTruthy,
  )
})
//#endregion

//#region countBy
describe("countBy", () => {
  test("source is empty", () => expect([]->countBy(x => x) == [])->toBeTruthy)

  test("source is int array", () =>
    expect([1, 1, 2, 2, 1, 3, 2]->countBy(x => x) == [(1, 3), (2, 3), (3, 1)])->toBeTruthy
  )

  test("source is object array", () => {
    let source = [
      {"Lang": "OCaml", "Score": 10},
      {"Lang": "ReScript", "Score": 10},
      {"Lang": "OCaml", "Score": 10},
      {"Lang": "TypeScript", "Score": 4},
    ]
    let res = source->countBy(x => x)
    expect(
      res == [
          ({"Lang": "OCaml", "Score": 10}, 2),
          ({"Lang": "ReScript", "Score": 10}, 1),
          ({"Lang": "TypeScript", "Score": 4}, 1),
        ],
    )->toBeTruthy
  })

  test("count by true or false", () =>
    expect(
      [1, 1, 2, 2, 1, 3, 2]->countBy(x => mod(x, 2) == 0) == [(false, 4), (true, 3)],
    )->toBeTruthy
  )
})
//#endregion

//#region scan
describe("scan", () => {
  test("should return initial state if the source is empty", () =>
    expect([]->scan((x, y) => x + y, 0) == [0])->toBeTruthy
  )

  test("should return correct result", () =>
    expect([1]->scan((x, y) => x + y, 0) == [0, 1])->toBeTruthy
  )

  test("should return correct result", () =>
    expect([1, 2, 3]->scan((x, y) => x + y, 0) == [0, 1, 3, 6])->toBeTruthy
  )
})

describe("scanRight", () => {
  test("should return initial state if the source is empty", () => {
    expect([]->scanRight((x, y) => x + y, 1) == [1])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([0]->scanRight((x, y) => x + y, 1) == [1, 1])->toBeTruthy
  })

  test("should return correct result", () => {
    expect(
      [0, 1, 2, 3, 4, 5]->scanRight((x, y) => x + y, 0) == [15, 15, 14, 12, 9, 5, 0],
    )->toBeTruthy
  })

  test("should return correct result", () => {
    expect(
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]->scanRight((x, y) => x + y, 0) == [
          55,
          54,
          52,
          49,
          45,
          40,
          34,
          27,
          19,
          10,
          0,
        ],
    )->toBeTruthy
  })
})
//#endregion

//#region unfold
describe("unfold", () => {
  test("should generate array having 1 to 5", () => {
    expect(unfold(x =>
        if x <= 5 {
          Some(x, x + 1)
        } else {
          None
        }
      , 1) == [1, 2, 3, 4, 5])->toBeTruthy
  })

  test("should generate fib 10", () => {
    let fib = n =>
      unfold(((x, (a, b))) => x < n ? Some(a + b, (x + 1, (b, a + b))) : None, (0, (0, 1)))
    expect(fib(10) == [1, 2, 3, 5, 8, 13, 21, 34, 55, 89])->toBeTruthy
  })
})
//#endregion

//#region mapFold
describe("mapFold", () => {
  test("should return ([],state) if the source array is empty", () => {
    expect([]->mapFold((x, y) => (x + y, x + y), 0) == ([], 0))->toBeTruthy
  })

  test("should return correct result", () => {
    let arr1To10 = Belt.Array.makeBy(10, x => x + 1)
    let result = arr1To10->mapFold((x, y) => (x + y, x + y), 0)
    let expected = ([1, 3, 6, 10, 15, 21, 28, 36, 45, 55], 55)
    expect(result == expected)->toBeTruthy
  })
})
//#endregion

//#region mapFoldRight
describe("mapFoldRight", () => {
  test("should return ([],state) if the source array is empty", () => {
    expect([]->mapFoldRight((x, y) => (x + y, x + y), 0) == ([], 0))->toBeTruthy
  })

  test("should return correct result", () => {
    let arr1To10 = Belt.Array.makeBy(10, x => x + 1)
    let result = arr1To10->mapFoldRight((x, y) => (x + y, x + y), 0)
    let expected = ([55, 54, 52, 49, 45, 40, 34, 27, 19, 10], 55)
    expect(result == expected)->toBeTruthy
  })
})
//#endregion

//#region distinct
describe("distinct", () => {
  test("should return empty array if source is empty", () => {
    expect([]->distinct == [])->toBeTruthy
  })

  test("test with int array", () => {
    expect([1, 1, 2, 2, 3, 3, 4, 4, 4]->distinct == [1, 2, 3, 4])->toBeTruthy
  })

  test("test with float array", () => {
    expect([1., 1., 2., 2., 3., 3., 4., 4., 4.]->distinct == [1., 2., 3., 4.])->toBeTruthy
  })

  test("test with string array", () => {
    expect(["abc", "def", "abc", "def", "def"]->distinct == ["abc", "def"])->toBeTruthy
  })

  test("test with option array", () => {
    Js.logMany([Some(1), Some(1), None, None, Some(2)]->distinct)
    expect(
      [Some(1), Some(1), None, None, Some(2)]->distinct == [None, Some(1), Some(2)],
    )->toBeTruthy
  })

  test("test with poly variants array", () => {
    expect([#RED, #GREEN, #BLUE, #RED, #GREEN, #BLUE]->distinct->length == 3)->toBeTruthy
  })

  test("test with record array", () => {
    expect(
      [{name: "a", age: 10.4}, {name: "a", age: 10.4}, {name: "a", age: 10.2}]->distinct == [
          {name: "a", age: 10.2},
          {name: "a", age: 10.4},
        ],
    )->toBeTruthy
  })

  test("test with object array", () => {
    expect(
      [
        {"name": "Jack", "age": 10.4},
        {"name": "Jack", "age": 10.4},
        {"name": "Bliss", "age": 10.2},
      ]->distinct == [{"name": "Bliss", "age": 10.2}, {"name": "Jack", "age": 10.4}],
    )->toBeTruthy
  })

  test("test with variant array", () => {
    expect(
      [
        Prism({width: (10., 10.), height: 20.}),
        Prism({width: (10., 10.), height: 20.}),
        Prism({width: (10., 10.), height: 21.}),
      ]->distinct == [
          Prism({width: (10., 10.), height: 20.}),
          Prism({width: (10., 10.), height: 21.}),
        ],
    )->toBeTruthy
  })
})
//#endregion

//#region distinctBy

describe("distinctBy", () => {
  test("should return empty array if source is empty", () => {
    expect([]->distinct == [])->toBeTruthy
  })

  test("test with int array", () => {
    expect([1, 1, 2, 2, 3, 3, 4, 4, 4]->distinctBy(x => mod(x, 2) == 0) == [1, 2])->toBeTruthy
  })

  test("test with float array", () => {
    expect([1., 1., 2., 2., 3., 3., 4., 4., 4.]->distinctBy(x => x >= 2.) == [1., 2.])->toBeTruthy
  })

  test("test with string array", () => {
    expect(["abc", "def", "abc", "def", "def"]->distinctBy(x => x) == ["abc", "def"])->toBeTruthy
  })

  test("test with option array", () => {
    expect(
      [Some(1), Some(1), None, None, Some(2)]->distinctBy(x => x) == [Some(1), None, Some(2)],
    )->toBeTruthy
  })

  test("test with poly variants array", () => {
    expect(
      [#RED, #GREEN, #BLUE, #RED, #GREEN, #BLUE]->distinctBy(x => x) == [#RED, #GREEN, #BLUE],
    )->toBeTruthy
  })

  test("test with record array", () => {
    expect(
      [{name: "a", age: 10.4}, {name: "b", age: 10.4}, {name: "c", age: 10.4}]->distinctBy(x =>
        x.age
      ) == [{name: "a", age: 10.4}],
    )->toBeTruthy
  })

  test("test with object array", () => {
    expect(
      [
        {"name": "Jack", "age": 10.4},
        {"name": "Jack", "age": 11.4},
        {"name": "Bliss", "age": 10.2},
      ]->distinctBy(x => x["name"]) == [
          {"name": "Jack", "age": 10.4},
          {"name": "Bliss", "age": 10.2},
        ],
    )->toBeTruthy
  })

  test("test with variant array", () => {
    expect(
      [
        Prism({width: (10., 10.), height: 20.}),
        Prism({width: (10., 10.), height: 20.}),
        Prism({width: (10., 10.), height: 21.}),
      ]->distinctBy(x => {
        switch x {
        | Prism({width, _}) => width
        | _ => (0., 0.) // this is crazy here. :-)
        }
      }) == [Prism({width: (10., 10.), height: 20.})],
    )->toBeTruthy
  })

  test("test with recursive variant type", () => {
    expect(
      [Any(2), Any(2), Any("two"), Any("two")]->distinctBy(x => x) == [Any(2), Any("two")],
    )->toBeTruthy
  })
})
//#endregion

//#region groupBy
describe("groupBy", () => {
  test("should return empty array if the source is empty", () => {
    expect([]->groupBy(x => x) == [])->toBeTruthy
  })

  test("test with int array", () => {
    expect(
      [1, 2, 3, 4, 5, 6]->groupBy(x => mod(x, 2) == 0) == [(false, [1, 3, 5]), (true, [2, 4, 6])],
    )->toBeTruthy
  })

  test("test with record array", () => {
    let langs = [
      {name: "Fsharp", family: {"name": "ML"}},
      {name: "OCaml", family: {"name": "ML"}},
      {name: "C++", family: {"name": "Smalltalk"}},
      {name: "C#", family: {"name": "Smalltalk"}},
      {name: "ReScript", family: {"name": "ML"}},
    ]
    let result = langs->groupBy(x => x.family["name"])
    expect(
      result == [
          (
            "ML",
            [
              {name: "Fsharp", family: {"name": "ML"}},
              {name: "OCaml", family: {"name": "ML"}},
              {name: "ReScript", family: {"name": "ML"}},
            ],
          ),
          (
            "Smalltalk",
            [
              {name: "C++", family: {"name": "Smalltalk"}},
              {name: "C#", family: {"name": "Smalltalk"}},
            ],
          ),
        ],
    )->toBeTruthy
  })

  test("record as key", () => {
    let persons = [
      {name: "Ryan", age: 5.},
      {name: "Ryan", age: 5.},
      {name: "ryan", age: 5.},
      {name: "Jack", age: 10.},
    ]
    let result = persons->groupBy(x => x)
    let expected = [
      ({name: "Ryan", age: 5.}, [{name: "Ryan", age: 5.}, {name: "Ryan", age: 5.}]),
      ({name: "ryan", age: 5.}, [{name: "ryan", age: 5.}]),
      ({name: "Jack", age: 10.}, [{name: "Jack", age: 10.}]),
    ]
    expect(result == expected)->toBeTruthy
  })
})
//#endregion

//#region skip
describe("skip", () => {
  test("should return empty array if the source is empty", () =>
    expect(([]: array<int>)->skip(10) == ([]: array<int>))->toBeTruthy
  )

  test("should return correct result", () =>
    expect(([1, 2, 3, 4, 5]: array<int>)->skip(2) == [1, 2, 3, 4, 5]->sliceFrom(2))->toBeTruthy
  )
})
//#endregion

//#region skipWhile

describe("skipWhile", () => {
  test("should return empty array if the source is empty", () =>
    expect(([]: array<int>)->skipWhile(x => x > 0) == ([]: array<int>))->toBeTruthy
  )

  test("should return correct result", () => {
    expect([1, 2, 3, 4]->skipWhile(x => mod(x, 2) == 0) == [1, 2, 3, 4])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3, 4]->skipWhile(x => mod(x, 2) == 1) == [2, 3, 4])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3, 4]->skipWhile(x => x < 3) == [3, 4])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3, 4]->skipWhile(x => x < 5) == [])->toBeTruthy
  })
})
//#endregion

//#region take
describe("take", () => {
  test("should return empty array if count is 0", () => {
    expect([1, 2, 3]->take(0) == [])->toBeTruthy
  })

  test("should throw error if count < 0", () => {
    expect(() => [1, 2, 3]->take(-1))->toThrow
  })

  test("should throw error if count > length of arr", () => {
    expect(() => [1, 2, 3]->take(5))->toThrow
  })

  test("should throw error if count > length of arr", () => {
    expect([1, 2, 3]->take(2) == [1, 2])->toBeTruthy
  })
})
//#endregion

//#region takeWhile
describe("takeWhile", () => {
  test("should return empty array if the source is empty", () => {
    expect([]->takeWhile(x => x > 2) == [])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3, 4, 5, 6]->takeWhile(x => x > 2) == [])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3, 4, 5, 6]->takeWhile(x => x < 2) == [1])->toBeTruthy
  })
})
//#endregion

//#region splitAt
describe("splitAt", () => {
  test("should throw error if index is greater than the lenght of the source", () => {
    expect(() => []->splitAt(1))->toThrow
  })

  test("index equals to the length of source", () => {
    expect([1, 2, 3]->splitAt(3) == ([1, 2, 3], []))->toBeTruthy
  })

  test("index is 0", () => {
    expect([1, 2, 3]->splitAt(0) == ([], [1, 2, 3]))->toBeTruthy
  })

  test("test an array containing one element", () => {
    expect([0]->splitAt(0) == ([], [0]))->toBeTruthy
  })

  test("index is less than the length of the source", () => {
    expect([1, 2, 3, 4, 5]->splitAt(3) == ([1, 2, 3], [4, 5]))->toBeTruthy
  })
})
//#endregion

//#region transpose
describe("transpose", () => {
  test("should return empty array if the source is empty", () =>
    expect([]->transpose == [])->toBeTruthy
  )

  test("should throw error if inner arrays have different length", () => {
    expect(() => [[1, 2], [1, 2, 3]]->transpose)->toThrow
  })

  test("should return correct result", () => {
    expect([[1, 2], [4, 5]]->transpose == [[1, 4], [2, 5]])->toBeTruthy
  })
})
//#endregion

//#region windowed
describe("windowed", () => {
  test("should throw error if size is less than zero", () => {
    expect(() => []->windowed(-1))->toThrow
  })

  test("should return empty array", () => {
    expect([]->windowed(1) == [])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3, 4, 5]->windowed(2) == [[1, 2], [2, 3], [3, 4], [4, 5]])->toBeTruthy
  })
})
//#endregion

//#region allPairs
describe("allPairs", () => {
  test("test with empty arrays", () => {
    expect(allPairs([], []) == [])->toBeTruthy
  })

  test("test with first array being empty", () => {
    expect(allPairs([], [1, 2, 3]) == [])->toBeTruthy
  })

  test("test with second array being empty", () => {
    expect(allPairs([1, 2], []) == [])->toBeTruthy
  })

  test("test with non empty arrays", () => {
    expect(allPairs([1, 2], [3, 4]) == [(1, 3), (1, 4), (2, 3), (2, 4)])->toBeTruthy
  })

  test("test with no empty arrays with different length", () => {
    expect(allPairs([1, 2], [1]) == [(1, 1), (2, 1)])->toBeTruthy
  })
})
//#endregion

//#region except
describe("except", () => {
  test("should return source array if source array or itemsToExclude is empty", () => {
    expect([]->except([1, 2]) == [])->toBeTruthy->ignore
    expect([1, 2, 3]->except([]) == [1, 2, 3])->toBeTruthy
  })

  test("should return correct result", () => {
    expect([1, 2, 3]->except([1, 2]) == [3])->toBeTruthy->ignore
    expect(
      [{"name": "abc"}, {"name": "abc"}, {"name": "def"}]->except([{"name": "abc"}]) == [
          {"name": "def"},
        ],
    )->toBeTruthy
  })
})
//#endregion

//#region head
describe("head", () => {
  test("throw error if the source array is empty", () => {
    expect(() => []->head)->toThrow
  })

  test("return the first element", () => {
    expect([1, 2]->head == 1)->toBeTruthy
  })
})
//#endregion

//#region tryHead
describe("tryHead", () => {
  test("return None if the source array is empty", () => {
    expect([]->tryHead == None)->toBeTruthy
  })

  test("return Some of the first element", () => {
    expect([1, 2]->tryHead == Some(1))->toBeTruthy
  })
})
//#endregion

//#region tail
describe("tail", () => {
  test("throw error if the source array is empty", () => {
    expect(() => []->tail)->toThrow
  })

  test("return empty if the source array contains a single element", () => {
    expect([1]->tail == [])->toBeTruthy
  })

  test("return the elements except the first one", () => {
    expect([1, 2, 4]->tail == [2, 4])->toBeTruthy
  })
})
//#endregion

//#region map2
describe("map2", () => {
  test("throw error if arr1 and arr2 don't have the same length", () => {
    expect(() => map2([1, 2], [1], (x, y) => x + y))->toThrow
  })

  test("should return correct result", () => {
    expect(map2([1, 2, 3], [4, 5, 6], (x, y) => x + y) == [5, 7, 9])->toBeTruthy
  })
})
//#endregion

//#region map3
describe("map3", () => {
  test("throw error if arr1, arr2 and arr3 don't have the same length", () => {
    expect(() => map3([1, 2], [1], [1, 2], (x, y, c) => x + y + c))->toThrow
  })

  test("should return correct result", () => {
    expect(
      map3([1, 2, 3], [4, 5, 6], [7, 8, 9], (x, y, z) => x + y + z) == [12, 15, 18],
    )->toBeTruthy
  })
})
//#endregion

//#region pairwise
describe("pairwise", () => {
  test("return empty if the length of the source arry is less than 2", () => {
    expect([]->pairwise == [])->toBeTruthy->ignore
    expect([1]->pairwise == [])->toBeTruthy
  })

  test("should return a correct result", () => {
    expect([1, 2]->pairwise == [(1, 2)])->toBeTruthy->ignore
    expect([1, 2, 3, 4]->pairwise == [(1, 2), (2, 3), (3, 4)])->toBeTruthy
  })
})
//#endregion

//#region minInt, minFloat, minFloat, maxFloat, sumInt, sumFloat, averageInt, averageFloat
describe("minInt, minFloat, minFloat, maxFloat, sumInt, sumFloat, averageInt, averageFloat", () => {
  let ints = Belt.Array.makeByU(10, (. x) => x + 1)
  let floats = Belt.Array.makeByU(10, (. x) => Js.Int.toFloat(x) +. 1.)

  test("throw error if the input array is empty", () => {
    expect(() => []->averageInt)->toThrow
  })

  test("throw error if the input array is empty", () => {
    expect(() => []->averageFloat)->toThrow
  })

  test("minInt", () => {
    expect(() => []->minInt)->toThrow
  })

  test("minInt correct result", () => {
    expect(ints->minInt == 1)->toBeTruthy
  })

  test("maxInt", () => {
    expect(() => []->maxInt)->toThrow
  })

  test("maxInt correct result", () => {
    expect(ints->maxInt == 10)->toBeTruthy
  })

  test("minFloat", () => {
    expect(() => []->minFloat)->toThrow
  })

  test("minFloat correct result", () => {
    expect(floats->minFloat == 1.)->toBeTruthy
  })

  test("maxFloat", () => {
    expect(() => []->maxFloat)->toThrow
  })

  test("maxFloat correct result", () => {
    expect(floats->maxFloat == 10.)->toBeTruthy
  })

  test("sumInt", () => {
    expect(ints->sumInt == 55)->toBeTruthy
  })

  test("sumInt", () => {
    expect([]->sumInt == 0)->toBeTruthy
  })

  test("sumFloat", () => {
    expect([]->sumFloat == 0.)->toBeTruthy
  })

  test("sumFloat", () => {
    expect(floats->sumFloat == 55.)->toBeTruthy
  })

  test("averageInt throws error", () => {
    expect(() => averageInt([]))->toThrow
  })

  test("averageInt", () => {
    expect(ints->averageInt == 55. /. 10.)->toBeTruthy
  })

  test("averageFloat throws error", () => {
    expect(() => averageFloat([]))->toThrow
  })

  test("averageFloat", () => {
    expect(floats->averageFloat == 55. /. 10.)->toBeTruthy
  })
})
//#endregion

//#region sumBy
describe("sumIntBy, sumFloatBy", () => {
  test("return 0 if the source arry is empty", () => {
    expect([]->sumIntBy(x => x) == 0)->toBeTruthy
  })

  test("should return correct result", () => {
    let people = [{"name": "abc", "age": 10}, {"name": "def", "age": 20}]
    expect(people->sumIntBy(x => x["age"]) == 30)->toBeTruthy->ignore
    expect([1, 2, 3, 4]->sumIntBy(x => mod(x, 2) == 0 ? x : 0) == 6)->toBeTruthy
  })

  test("return 0 if the source arry is empty", () => {
    expect([]->sumFloatBy(x => x) == 0.)->toBeTruthy
  })

  test("should return correct result", () => {
    let people = [{"name": "abc", "age": 10.}, {"name": "def", "age": 20.}]
    expect(people->sumFloatBy(x => x["age"]) == 30.)->toBeTruthy->ignore
    expect([1, 2, 3, 5]->sumFloatBy(x => x > 2 ? Js.Int.toFloat(x) : 0.) == 8.)->toBeTruthy
  })
})
//#endregion

//#region minBy
describe("minBy", () => {
  test("throw error if the source array is empty", () => {
    expect(() => []->minBy(x => x))->toThrow
  })

  test("should return correct result", () => {
    let people = [{"name": "abc", "age": 10.}, {"name": "def", "age": 20.}]
    expect(people->minBy(x => x["age"]) == {"name": "abc", "age": 10.})->toBeTruthy
  })
})
//#endregion

//#region maxBy
describe("maxBy", () => {
  test("throw error if the source array is empty", () => {
    expect(() => []->maxBy(x => x))->toThrow
  })

  test("should return correct result", () => {
    let people = [{"name": "abc", "age": 10.}, {"name": "def", "age": 20.}]
    expect(people->maxBy(x => x["age"]) == {"name": "def", "age": 20.})->toBeTruthy
  })
})
//#endregion

//#region averabeInt/FloatBy
describe("averageIntBy/averageFloatBy", () => {
  test("averageIntBy throws error", () => {
    expect(() => []->averageIntBy(x => x))->toThrow
  })

  test("averageFloatBy throws error", () => {
    expect(() => []->averageFloatBy(x => x))->toThrow
  })

  test("return correct answer", () => {
    expect([1, 2, 3, 4, 5]->averageIntBy(x => x > 2 ? x : 0) == 2.4)->toBeTruthy
  })

  test("return correct answer", () => {
    expect([1., 2., 3., 4., 5.]->averageFloatBy(x => x > 2. ? x : 0.) == 2.4)->toBeTruthy
  })
})
//#endregion
