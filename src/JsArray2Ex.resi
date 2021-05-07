include module type of Js.Array2

let chunkBySize: (t<'a>, int) => t<t<'a>>

let countBy: (t<'a>, 'a => 'key) => t<('key, int)>

let scan: (t<'a>, ('b, 'a) => 'b, 'b) => t<'b>

let scanRight: (t<'a>, ('a, 'b) => 'b, 'b) => t<'b>

let unfold: ('a => option<('b, 'a)>, 'a) => t<'b>

let mapFold: (t<'a>, ('b, 'a) => ('c, 'b), 'b) => (t<'c>, 'b)

let mapFoldRight: (t<'a>, ('a, 'b) => ('c, 'b), 'b) => (t<'c>, 'b)

let distinct: t<'a> => t<'a>

let distinctBy: (t<'a>, 'a => 'b) => t<'a>

let groupBy: (t<'a>, 'a => 'b) => t<('b, t<'a>)>

let skip: (t<'a>, int) => t<'a>

let skipWhile: (t<'a>, 'a => bool) => t<'a>

let take: (t<'a>, int) => t<'a>

let takeWhile: (t<'a>, 'a => bool) => t<'a>