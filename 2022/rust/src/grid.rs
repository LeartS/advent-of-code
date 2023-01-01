use num::Integer;

pub fn taxicab_neighbours(
    width: usize,
    height: usize,
    (r, c): (usize, usize),
) -> impl Iterator<Item = (usize, usize)> {
    let candidates = match (r, c) {
        (0, 0) => vec![(r, c + 1), (r + 1, c)],
        (0, _) => vec![(r, c + 1), (r + 1, c), (r, c - 1)],
        (_, 0) => vec![(r - 1, c), (r, c + 1), (r + 1, c)],
        (_, _) => vec![(r - 1, c), (r, c + 1), (r + 1, c), (r, c - 1)],
    };
    candidates
        .into_iter()
        .filter(move |&(r, c)| r < height && c < width)
}

pub fn taxicab_distance<T: Integer + Copy>(
    (x1, y1): (T, T),
    (x2, y2): (T, T),
) -> T {
    std::cmp::max(x1, x2) - std::cmp::min(x1, x2) + std::cmp::max(y1, y2) - std::cmp::min(y1, y2)
}

