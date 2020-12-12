use itertools::Itertools;
use std::cmp::min;
use std::collections::HashMap;
use std::io::{self, BufRead};

type Grid = Vec<Vec<char>>;

fn simulate_one<F>(grid: &Grid, seats_to_check_generator: &F, min_to_leave: usize) -> Grid
// where F: Fn(&Grid, (usize, usize)) -> impl Iterator<Item=(usize, usize)> {
where
    F: Fn(&Grid, (usize, usize)) -> Vec<(usize, usize)>,
{
    let mut next_grid = grid.clone();
    for (r, row) in grid.iter().enumerate() {
        for (c, cell) in row.iter().enumerate() {
            let occupied = seats_to_check_generator(grid, (r, c))
                .iter()
                .filter(|(ar, ac)| grid[*ar][*ac] == '#')
                .count();
            next_grid[r][c] = match (cell, occupied) {
                ('L', 0) => '#',
                ('#', n) if n >= min_to_leave => 'L',
                (&s, _) => s,
            }
        }
    }
    next_grid
}

fn simulate_until_stable<F>(grid: &Grid, generator: F, min_to_leave: usize) -> (usize, Grid)
where
    F: Fn(&Grid, (usize, usize)) -> Vec<(usize, usize)>,
{
    let mut grid: Grid = grid.clone();
    std::iter::from_fn(|| match simulate_one(&grid, &generator, min_to_leave) {
        next if next == grid => None,
        next => {
            grid = next;
            Some(grid.to_owned())
        }
    })
    .into_iter()
    .enumerate()
    .last()
    .unwrap()
}

// fn adjacent(grid: &Grid, position: (usize, usize)) -> impl Iterator<Item=(usize, usize)> {
fn adjacent(grid: &Grid, position: (usize, usize)) -> Vec<(usize, usize)> {
    let (width, height) = (grid[0].len(), grid.len());
    let (r, c) = position;
    (r.saturating_sub(1)..=min(r + 1, height - 1))
        .cartesian_product(c.saturating_sub(1)..=min(c + 1, width - 1))
        .filter(|(ar, ac)| *ar != r || *ac != c)
        .collect()
}

fn within_bounds((width, height): (isize, isize), (r, c): (isize, isize)) -> bool {
    r >= 0 && r < height && c >= 0 && c < width
}

fn visible(grid: &Grid, position: (usize, usize)) -> Vec<(usize, usize)> {
    let (r, c) = (position.0 as isize, position.1 as isize);
    let (width, height) = (grid[0].len(), grid.len());
    [
        (-1, 0),
        (-1, 1),
        (0, 1),
        (1, 1),
        (1, 0),
        (1, -1),
        (0, -1),
        (-1, -1),
    ]
    .iter()
    .map(|&(v, h): &(isize, isize)| {
        (1..)
            .map(move |n: isize| (r + v * n, c + h * n))
            .take_while(|&pos| within_bounds((width as isize, height as isize), pos))
            .map(|(r, c)| (r as usize, c as usize))
            .find(|&(r, c)| grid[r][c] != '.')
    })
    .flatten()
    .collect::<Vec<_>>()
}

// Idea: because the visible seats from each position depend only on the
// floorplan and not on the current generation empty/occupied seats, we can
// preocompute the visible seats into an hashmap and then just return from there
// (cool, but more simply we could cache the invocations to `visible` for the
// same effect)
// fn build_visible_generator(_grid: &Grid) -> impl Fn(&Grid, (usize, usize)) -> Vec<(usize, usize)> {

//     // call visible() for every position, and save the result in an
//     // hashmap
//     let visible_seats: HashMap<(usize, usize), Vec<(usize, usize)>> = HashMap::new();

//     // return a precomputed version of `visible` that just reads from
//     // the precomputed hashmap
//     let k = move |_grid: &Grid, position: (usize, usize)| {
//         visible_seats
//             .get(&position)
//             .expect("something wrong")
//             .to_owned()
//     };
//     k
// }

fn count_occupied(grid: &Grid) -> usize {
    grid.iter()
        .map(|x| x.iter())
        .flatten()
        .filter(|x| x == &&'#')
        .count()
}

pub fn print_grid(grid: &Grid) {
    let k = grid.iter().map(|x| x.iter().join("")).join("\n");
    println!("{}", k);
}

fn part1(grid: &Grid) {
    let (generations, final_grid) = simulate_until_stable(grid, adjacent, 4);
    println!(
        "{} occupied seats once stable after {} generations",
        count_occupied(&final_grid),
        generations
    )
}

fn part2(grid: &Grid) {
    let (generations, final_grid) = simulate_until_stable(grid, visible, 5);
    println!(
        "{} occupied seats once stable after {} generations",
        count_occupied(&final_grid),
        generations
    )
}

pub fn main() {
    let grid: Grid = io::stdin()
        .lock()
        .lines()
        .map(|l| l.unwrap().chars().collect_vec())
        .collect();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&grid),
        Some(p) if p == "part2" => part2(&grid),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
