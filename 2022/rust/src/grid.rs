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
