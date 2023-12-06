pub type Array(a)

@external(erlang, "array", "size")
fn array_size(array: Array(a)) -> Int

@external(erlang, "array", "new")
fn new_array(size: Int) -> Array(a)

@external(erlang, "array", "from_list")
fn array_from_list(l: List(a)) -> Array(a)

@external(erlang, "array", "set")
fn array_set(index: Int, value: a, arr: Array(a)) -> Array(a)

@external(erlang, "array", "get")
fn array_get(index: Int, arr: Array(a)) -> a

@external(erlang, "array", "foldr")
fn array_fold(reducer: fn(Int, a, b) -> b, initial: b, arr: Array(a)) -> b

@external(erlang, "array", "to_list")
fn array_to_list(arr: Array(a)) -> List(a)

@external(erlang, "array", "map")
fn array_map(function: fn(Int, a) -> b, arr: Array(a)) -> Array(b)

@external(erlang, "array", "to_orddict")
fn array_to_tuple_list(arr: Array(a)) -> List(#(Int, a))

@external(erlang, "array", "from_orddict")
fn array_from_tuple_list(l: List(#(Int, a))) -> Array(a)

pub fn new(size: Int) -> Array(a) {
  new_array(size)
}

pub fn from_list(l: List(a)) -> Array(a) {
  array_from_list(l)
}

pub fn to_list(arr: Array(a)) -> List(a) {
  array_to_list(arr)
}

pub fn size(arr: Array(a)) -> Int {
  array_size(arr)
}

pub fn set(arr: Array(a), index: Int, value: a) -> Array(a) {
  array_set(index, value, arr)
}

pub fn get(arr: Array(a), index: Int) -> a {
  array_get(index, arr)
}

pub fn fold(arr: Array(a), initial: b, reducer: fn(a, b) -> b) -> b {
  array_fold(fn(_, item, accum) { reducer(item, accum) }, initial, arr)
}

pub fn map(arr: Array(a), mapper: fn(a, Int) -> b) -> Array(b) {
  array_map(fn(index, item) { mapper(item, index) }, arr)
}

pub fn to_pairs(arr: Array(a)) -> List(#(Int, a)) {
  array_to_tuple_list(arr)
}

pub fn from_pairs(l: List(#(Int, a))) -> Array(a) {
  array_from_tuple_list(l)
}
