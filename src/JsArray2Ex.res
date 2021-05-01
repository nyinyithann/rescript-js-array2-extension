include Js.Array2

exception InvalidArgument(string)

let chunkBySize = (arr: array<'a>, chunkSize: int) => {
  let result: array<array<'a>> = []
  let len = arr->length
  if chunkSize <= 0 {
    raise(InvalidArgument("chunkSize must be positive."))
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

let countBy: (array<'a>, 'a => 'key) => array<('key, int)> = (arr, projection) => {
  let len = arr->length
  if len == 0 {
    ([]: array<('key, int)>)
  } else {
    let result: array<('key, int)> = []
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
