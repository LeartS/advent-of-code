import gleam/iterator
import gleam/set

/// Stops the iterator at the first occurrence of a repeated element
/// 
/// ## Examples
/// 
/// ```gleam
/// > [1,2,3,4,2,5,3,4]
/// > |> iterator.from_list()
/// > |> take_until_loop()
/// 
/// [1,2,3,4,2]
/// ```
pub fn take_until_repeating(it: iterator.Iterator(a)) -> iterator.Iterator(a) {
  iterator.transform(
    over: it,
    from: #(False, set.new()),
    with: fn(acc: #(Bool, set.Set(a)), el: a) {
      let #(exit, seen) = acc
      case exit, set.contains(seen, el) {
        True, _ -> iterator.Done
        False, True -> iterator.Next(el, #(True, seen))
        False, False -> iterator.Next(el, #(False, set.insert(seen, el)))
      }
    },
  )
}
