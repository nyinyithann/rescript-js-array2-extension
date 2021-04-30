open Jest
open ExpectJs
open JsArray2Ex

describe("chunkBySize", () => {
  let arr = [1, 2, 3, 4, 5, 6, 7]

  test("throw exception if chunkSize is not positive", () => {
    expect(() => chunkBySize(arr, -1))->toThrow
  })

  test("return an empty array if the source is empty", () =>
    expect([]->chunkBySize(2) == [])->toBeTruthy
  )

  test(
    "return an array containing the source if chunkSize is greater than the length of the source",
    () => expect(arr->chunkBySize(100) == [[1, 2, 3, 4, 5, 6, 7]])->toBeTruthy,
  )

  test("should return correct answer", () =>
    expect(arr->chunkBySize(2) == [[1, 2], [3, 4], [5, 6], [7]])->toBeTruthy
  )

  test("should return correct answer", () => {
    expect(arr->chunkBySize(length(arr)) == [arr])->toBeTruthy
  })
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
    expect([1, 1, 2, 2, 1, 3, 2]->countBy(x => mod(x,2) == 0) == [(false, 4), (true, 3)])->toBeTruthy
  )
})
