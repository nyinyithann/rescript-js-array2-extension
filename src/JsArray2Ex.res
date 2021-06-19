include Js.Array2

exception Invalid_argument(string)
exception Invalid_operation(string)

@new external create: int => t<'a> = "Array"

let chunkBySize: (t<'a>, int) => t<t<'a>> = (arr, chunkSize) => {
  let result: t<t<'a>> = []
  let len = arr->length
  if chunkSize <= 0 {
    raise(Invalid_argument("chunkSize must be positive."))
  }
  if len == 0 {
    result
  } else if chunkSize > len {
    result->push(copy(arr))->ignore
    result
  } else {
    let chunkCount = (len - 1) / chunkSize + 1
    for i in 0 to len / chunkSize - 1 {
      let start = i * chunkSize
      let end_ = start + chunkSize
      result->push(slice(arr, ~start, ~end_))->ignore
    }
    if mod(len, chunkSize) != 0 {
      let start = (chunkCount - 1) * chunkSize
      let end_ = len
      result->push(slice(arr, ~start, ~end_))->ignore
    }
    result
  }
}

let countBy = (type k, arr: t<'a>, projection: 'a => k) => {
  let len = arr->length
  if len == 0 {
    ([]: t<(k, int)>)
  } else {
    module Comparable = Belt.Id.MakeComparable({
      type t = k
      let cmp = Pervasives.compare
    })
    let map = Belt.MutableMap.make(~id=module(Comparable))
    for i in 0 to len - 1 {
      let item = arr[i]
      let key = projection(item)
      map->Belt.MutableMap.update(key, v => {
        switch v {
        | None => Some(1)
        | Some(x) => Some(x + 1)
        }
      })
    }
    Belt.MutableMap.toArray(map)
  }
}

let scan: (t<'a>, ('b, 'a) => 'b, 'b) => t<'b> = (arr, folder, initialState) => {
  let len = arr->length
  let result: t<'b> = [initialState]

  let rec loop = (i, state) => {
    if i <= len - 1 {
      let newState = folder(state, arr[i])
      result->push(newState)->ignore
      loop(i + 1, newState)
    }
  }
  loop(0, initialState)
  result
}

let scanRight: (t<'a>, ('a, 'b) => 'b, 'b) => t<'b> = (arr, folder, initialState) => {
  let len = arr->length
  let result: t<'b> = create(len + 1)
  result[len] = initialState

  let rec loop = (i, state) => {
    if i >= 0 {
      let newState = folder(arr[i], state)
      result[i] = newState
      loop(i - 1, newState)
    }
  }
  loop(len - 1, initialState)
  result
}

let unfold: ('a => option<('b, 'a)>, 'a) => t<'b> = (generator, state) => {
  let result: t<'b> = []
  let rec loop = s => {
    switch generator(s) {
    | Some(x, xs) => {
        result->push(x)->ignore
        loop(xs)
      }
    | _ => ()
    }
  }
  loop(state)
  result
}

let mapFold: (t<'a>, ('b, 'a) => ('c, 'b), 'b) => (t<'c>, 'b) = (arr, mapping, state) => {
  switch arr->length {
  | 0 => ([], state)
  | len => {
      let result: t<'c> = create(len)
      let acc = ref(state)
      for i in 0 to len - 1 {
        let (c, b) = mapping(acc.contents, arr[i])
        result[i] = c
        acc := b
      }
      (result, acc.contents)
    }
  }
}

let mapFoldRight: (t<'a>, ('a, 'b) => ('c, 'b), 'b) => (t<'c>, 'b) = (arr, mapping, state) => {
  switch arr->length {
  | 0 => ([], state)
  | len => {
      let result: t<'c> = create(len)
      let acc = ref(state)
      for i in len - 1 downto 0 {
        let (c, b) = mapping(arr[i], acc.contents)
        result[i] = c
        acc := b
      }
      (result, acc.contents)
    }
  }
}

let distinct = (type a, arr: t<a>) => {
  module Comparable = Belt.Id.MakeComparable({
    type t = a
    let cmp = Pervasives.compare
  })
  let set = Belt.MutableSet.fromArray(arr, ~id=module(Comparable))
  Belt.MutableSet.toArray(set)
}

let distinctBy = (type k, arr: t<'a>, projection: 'a => k) => {
  let result: t<'a> = []
  module Comparable = Belt.Id.MakeComparable({
    type t = k
    let cmp = Pervasives.compare
  })
  let set = Belt.MutableSet.make(~id=module(Comparable))
  let len = arr->length
  for i in 0 to len - 1 {
    let item = arr[i]
    let key = projection(item)
    if !(set->Belt.MutableSet.has(key)) {
      result->push(item)->ignore
      set->Belt.MutableSet.add(key)
    }
  }
  result
}

let groupBy = (type k, arr: t<'a>, projection: 'a => k) => {
  let len = arr->length
  module Comparable = Belt.Id.MakeComparable({
    type t = k
    let cmp = Pervasives.compare
  })
  let map = Belt.MutableMap.make(~id=module(Comparable))
  for i in 0 to len - 1 {
    let item = arr[i]
    let key = projection(item)
    map->Belt.MutableMap.update(key, v => {
      switch v {
      | None => Some([item])
      | Some(x) =>
        x->push(item)->ignore
        Some(x)
      }
    })
  }
  Belt.MutableMap.toArray(map)
}

let skip: (t<'a>, int) => t<'a> = (arr, count) => {
  arr->sliceFrom(count)
}

let skipWhile: (t<'a>, 'a => bool) => t<'a> = (arr, predicate) => {
  let len = arr->length
  let i = ref(0)
  while i.contents < len && predicate(arr[i.contents]) {
    i := i.contents + 1
  }

  switch len - i.contents {
  | 0 => []
  | _ => arr->sliceFrom(i.contents)
  }
}

let take: (t<'a>, int) => t<'a> = (arr, count) => {
  switch count {
  | 0 => []
  | _ if count < 0 => raise(Invalid_argument("count must be positive."))
  | _ if count > arr->length => raise(Invalid_operation("arr doesn't have enough elements."))
  | _ => arr->slice(~start=0, ~end_=count)
  }
}

let takeWhile: (t<'a>, 'a => bool) => t<'a> = (arr, predicate) => {
  switch arr->length {
  | 0 => []
  | len => {
      let count = ref(0)
      while count.contents < len && predicate(arr[count.contents]) {
        count := count.contents + 1
      }
      arr->slice(~start=0, ~end_=count.contents)
    }
  }
}

let splitAt: (t<'a>, int) => (t<'a>, t<'a>) = (arr, index) => {
  let len = arr->length
  if len < index {
    raise(Invalid_operation("The source has an insufficient number of elements."))
  }

  if index == 0 {
    ([], arr->sliceFrom(0))
  } else if len == index {
    (arr->sliceFrom(0), [])
  } else {
    (arr->slice(~start=0, ~end_=index), arr->sliceFrom(index))
  }
}

let transpose: t<t<'a>> => t<t<'a>> = arr => {
  let len = arr->length

  if len == 0 {
    []
  } else {
    let lenInner = arr[0]->length
    for j in 0 to len - 1 {
      if lenInner != arr[j]->length {
        raise(Invalid_argument("all element of the source array should have the same length"))
      }
    }

    let result: t<t<'a>> = create(lenInner)
    for i in 0 to lenInner - 1 {
      result[i] = create(len)
      for j in 0 to len - 1 {
        result[i][j] = arr[j][i]
      }
    }

    result
  }
}

let windowed: (t<'a>, int) => t<t<'a>> = (arr, size) => {
  if size <= 0 {
    raise(Invalid_argument("size must be greater than 0"))
  }
  let len = arr->length
  if size > len {
    []
  } else {
    let result: t<t<'a>> = create(len - size + 1)
    for i in 0 to len - size {
      result[i] = arr->slice(~start=i, ~end_=size + i)
    }
    result
  }
}

let allPairs: (t<'a>, t<'b>) => t<('a, 'b)> = (arr1, arr2) => {
  let len1 = arr1->length
  let len2 = arr2->length
  let result = create(len1 * len2)

  for i in 0 to len1 - 1 {
    for j in 0 to len2 - 1 {
      result[i * len2 + j] = (arr1[i], arr2[j])
    }
  }
  result
}

let except: (t<'a>, t<'a>) => t<'a> = (arr, itemsToExclude) => {
  let len = arr->length
  let lenExclude = itemsToExclude->length
  if len == 0 || lenExclude == 0 {
    arr
  } else {
    let result = []
    for i in 0 to len - 1 {
      switch itemsToExclude->findIndex(x => x == arr[i]) {
      | -1 => result->push(arr[i])->ignore
      | _ => ()
      }
    }
    result
  }
}

let head: t<'a> => 'a = arr => {
  if arr->length == 0 {
    raise(Invalid_argument("The source array is empty."))
  } else {
    arr[0]
  }
}

let tryHead: t<'a> => option<'a> = arr => {
  switch arr->length {
  | 0 => None
  | _ => Some(arr[0])
  }
}

let tail: t<'a> => t<'a> = arr => {
  if arr->length == 0 {
    raise(Invalid_argument("The source array is empty."))
  } else {
    arr->sliceFrom(1)
  }
}

let map2: (t<'a>, t<'b>, ('a, 'b) => 'c) => t<'c> = (arr1, arr2, mapping) => {
  let len1 = arr1->length
  let len2 = arr2->length

  if len1 != len2 {
    raise(Invalid_argument("arr1 and arr2 should have the same length."))
  }

  let result: t<'c> = create(len1)
  for i in 0 to len1 - 1 {
    result[i] = mapping(arr1[i], arr2[i])
  }
  result
}

let map3: (t<'a>, t<'b>, t<'c>, ('a, 'b, 'c) => 'd) => t<'d> = (arr1, arr2, arr3, mapping) => {
  let len1 = arr1->length
  let len2 = arr2->length
  let len3 = arr3->length

  if len1 != len2 || len1 != len3 {
    raise(Invalid_argument("arr1, arr2, and arr3 should have the same length."))
  }

  let result: t<'d> = create(len1)
  for i in 0 to len1 - 1 {
    result[i] = mapping(arr1[i], arr2[i], arr3[i])
  }
  result
}

let pairwise: t<'a> => t<('a, 'a)> = arr => {
  let len = arr->length
  if len < 2 {
    []
  } else {
    Belt.Array.makeByU(len - 1, (. i) => (arr[i], arr[i + 1]))
  }
}

let minInt: t<int> => int = arr => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_operation("The source array should not be empty."))
  }

  let min = ref(arr[0])
  for i in 1 to len - 1 {
    let n = arr[i]
    if min.contents > n {
      min := n
    }
  }
  min.contents
}

let maxInt: t<int> => int = arr => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_operation("The source array should not be empty."))
  }

  let max = ref(arr[0])
  for i in 1 to len - 1 {
    let n = arr[i]
    if max.contents < n {
      max := n
    }
  }
  max.contents
}

let minFloat: t<float> => float = arr => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_operation("The source array should not be empty."))
  }

  let min = ref(arr[0])
  for i in 1 to len - 1 {
    let n = arr[i]
    if min.contents > n {
      min := n
    }
  }
  min.contents
}

let maxFloat: t<float> => float = arr => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_operation("The source array should not be empty."))
  }

  let max = ref(arr[0])
  for i in 1 to len - 1 {
    let n = arr[i]
    if max.contents < n {
      max := n
    }
  }
  max.contents
}

let sumInt: t<int> => int = arr => {
  arr->reduce((x, y) => x + y, 0)
}

let sumFloat: t<float> => float = arr => {
  arr->reduce((x, y) => x +. y, 0.)
}

let averageInt: t<int> => float = arr => {
  if arr->length == 0 {
    raise(Invalid_argument("The input array should not be empty."))
  }
  Js.Int.toFloat(sumInt(arr)) /. Js.Int.toFloat(length(arr))
}

let averageFloat: t<float> => float = arr => {
  if arr->length == 0 {
    raise(Invalid_argument("The input array should not be empty."))
  }
  sumFloat(arr) /. Js.Int.toFloat(length(arr))
}

let sumIntBy: (t<'a>, 'a => int) => int = (arr, projection) => {
  let sum = ref(0)
  let len = arr->length
  for i in 0 to len - 1 {
    sum := sum.contents + projection(arr[i])
  }
  sum.contents
}

let sumFloatBy: (t<'a>, 'a => float) => float = (arr, projection) => {
  let sum = ref(0.)
  let len = arr->length
  for i in 0 to len - 1 {
    sum := sum.contents +. projection(arr[i])
  }
  sum.contents
}

let minBy: (t<'a>, 'a => 'b) => 'a = (arr, projection) => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_argument("The input array should not be empty."))
  }

  let min = ref(arr[0])
  let x = ref(projection(arr[0]))
  for i in 1 to len - 1 {
    let a = arr[i]
    let b = projection(a)
    if b < x.contents {
      min := a
      x := b
    }
  }
  min.contents
}

let maxBy: (t<'a>, 'a => 'b) => 'a = (arr, projection) => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_argument("The input array should not be empty."))
  }

  let max = ref(arr[0])
  let x = ref(projection(arr[0]))
  for i in 1 to len - 1 {
    let a = arr[i]
    let b = projection(a)
    if b > x.contents {
      max := a
      x := b
    }
  }
  max.contents
}

let averageIntBy: (t<'a>, 'a => int) => float = (arr, projection) => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_argument("The input array should not be empty."))
  }
  let sum = ref(0)
  for i in 0 to len - 1 {
    sum := sum.contents + projection(arr[i])
  }
  Js.Int.toFloat(sum.contents) /. Js.Int.toFloat(len)
}

let averageFloatBy: (t<'a>, 'a => float) => float = (arr, projection) => {
  let len = arr->length
  if len == 0 {
    raise(Invalid_argument("The input array should not be empty."))
  }
  let sum = ref(0.0)
  for i in 0 to len - 1 {
    sum := sum.contents +. projection(arr[i])
  }
  sum.contents /. Js.Int.toFloat(len)
}
