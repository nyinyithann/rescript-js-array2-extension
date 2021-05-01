include module type of Js.Array2

let chunkBySize: (t<'a>, int) => t<t<'a>>

let countBy: (t<'a>, 'a => 'key) => t<('key, int)>

let scan: (t<'a>, ('b, 'a) => 'b, 'b) => t<'b>

let scanRight: (t<'a>, ('a, 'b) => 'b, 'b) => t<'b>