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

let countBy: (t<'a>, 'a => 'key) => t<('key, int)> = (arr, projection) => {
  let len = arr->length
  if len == 0 {
    ([]: t<('key, int)>)
  } else {
    let result: t<('key, int)> = []
    for i in 0 to len - 1 {
      let key = projection(arr[i])
      let idx = result->findIndex(x => {
        let (k, _) = x
        k == key
      })
      if idx > -1 {
        let (k, v) = result[idx]
        result[idx] = (k, v + 1)
      } else {
        result->push((key, 1))->ignore
      }
    }
    result
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

let distinct: t<'a> => t<'a> = arr => {
  let result: t<'a> = []
  let len = arr->length
  for i in 0 to len - 1 {
    switch result->findIndex(x => x == arr[i]) {
    | -1 => result->push(arr[i])->ignore
    | _ => ()
    }
  }
  result
}

let distinctBy: (t<'a>, 'a => 'b) => t<'a> = (arr, projection) => {
  let result: t<'a> = []
  let keys: t<'b> = []
  let len = arr->length
  for i in 0 to len - 1 {
    let key = projection(arr[i])
    switch keys->findIndex(x => x == key) {
    | -1 => {
        result->push(arr[i])->ignore
        keys->push(key)->ignore
      }
    | _ => ()
    }
  }
  result
}

let groupBy: (t<'a>, 'a => 'b) => t<('b, t<'a>)> = (arr, projection) => {
  let len = arr->length
  let result: array<('b, t<'a>)> = []
  for i in 0 to len - 1 {
    let key = projection(arr[i])
    switch result->findIndex(((k, _)) => k == key) {
    | -1 => result->push((key, [arr[i]]))->ignore
    | idx => {
        let (_, v) = result[idx]
        v->push(arr[i])->ignore
      }
    }
  }
  result
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
