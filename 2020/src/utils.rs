use multiset::HashMultiSet;
use std::cmp::{Eq, PartialOrd};
use std::hash::Hash;
use std::ops::{Add, Sub};

pub fn find_couple_with_sum<T>(numbers: &[T], sum: T) -> Option<(T, T)>
where
    T: Sub<Output = T> + Add<Output = T> + Copy + Eq + PartialOrd + Hash,
{
    let number_set: HashMultiSet<&T> = numbers.into_iter().collect();
    numbers.iter().filter(|&n1| *n1 <= sum).find_map(|&n1| {
        let n2 = sum - n1;
        match number_set.count_of(&&n2) {
            c if n1 != n2 && c >= 1 => Some((n1, n2)),
            c if c >= 2 => Some((n1, n2)),
            _ => None,
        }
    })
}
