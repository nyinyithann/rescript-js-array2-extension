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

let splitAt: (t<'a>, int) => (t<'a>, t<'a>)

let transpose: t<t<'a>> => t<t<'a>>

let windowed: (t<'a>, int) => t<t<'a>>

let allPairs: (t<'a>, t<'b>) => t<('a, 'b)>

let except: (t<'a>, t<'a>) => t<'a>

let head: t<'a> => 'a

let tryHead: t<'a> => option<'a>

let tail: t<'a> => t<'a>

let map2: (t<'a>, t<'b>, ('a, 'b) => 'c) => t<'c>

let map3: (t<'a>, t<'b>, t<'c>, ('a, 'b, 'c) => 'd) => t<'d>

let pairwise: t<'a> => t<('a, 'a)>

let minInt: t<int> => int

let maxInt: t<int> => int

let minFloat: t<float> => float

let maxFloat: t<float> => float

let sumInt: t<int> => int

let sumFloat: t<float> => float

let averageInt: t<int> => float

let averageFloat: t<float> => float

let sumIntBy: (t<'a>, 'a => int) => int

let sumFloatBy: (t<'a>, 'a => float) => float

let minBy: (t<'a>, 'a => 'b) => 'a

let maxBy: (t<'a>, 'a => 'b) => 'a

let averageIntBy: (t<'a>, 'a => int) => float

let averageFloatBy: (t<'a>, 'a => float) => float

