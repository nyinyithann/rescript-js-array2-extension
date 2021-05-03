open Jest
open ExpectJs
open JsArray2Ex

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
