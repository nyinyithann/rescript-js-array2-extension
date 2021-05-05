open Jest
open ExpectJs
open JsArray2Ex

type person = {name: string, age: float}
type shape =
  | Rectangle({width: float, height: float})
  | Circle({radius: float})
  | Prism({width: (float, float), height: float})

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
    Js.log(None == None)
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
