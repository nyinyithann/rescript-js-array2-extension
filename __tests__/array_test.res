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
    expect(
      [Some(1), Some(1), None, None, Some(2)]->distinct == [Some(1), None, Some(2)],
    )->toBeTruthy
  })

  test("test with poly variants array", () => {
    expect(
      [#RED, #GREEN, #BLUE, #RED, #GREEN, #BLUE]->distinct == [#RED, #GREEN, #BLUE],
    )->toBeTruthy
  })

  test("test with record array", () => {
    expect(
      [{name: "a", age: 10.4}, {name: "a", age: 10.4}, {name: "a", age: 10.2}]->distinct == [
          {name: "a", age: 10.4},
          {name: "a", age: 10.2},
        ],
    )->toBeTruthy
  })

  test("test with object array", () => {
    expect(
      [
        {"name": "Jack", "age": 10.4},
        {"name": "Jack", "age": 10.4},
        {"name": "Bliss", "age": 10.2},
      ]->distinct == [{"name": "Jack", "age": 10.4}, {"name": "Bliss", "age": 10.2}],
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
    Js.log([1, 2, 3, 4, 5]->windowed(2))
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
