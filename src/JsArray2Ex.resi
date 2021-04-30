include module type of Js.Array2

let chunkBySize: (array<'a>, int) => array<array<'a>>

let countBy: (array<'a>, 'a => 'key) => array<('key, int)>
