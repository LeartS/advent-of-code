use std::io::{self, BufRead};
use itertools::Itertools;

type Grid = Vec<Vec<char>>;

fn generation(grid: &Grid) -> Grid {
    let mut next_grid = grid.clone();
    for (r, row) in grid.iter().enumerate() {
        for (c, cell) in row.iter().enumerate() {
            let adj_occupied = (r.saturating_sub(1)..=r+1)
                .cartesian_product(c.saturating_sub(1)..=c+1)
                .filter(|&(ar, ac)| ar != r || ac != c)
                .filter(|&(ar, ac)| ar < grid.len() && ac < row.len())
                .filter(|&(ar, ac)| grid[ar][ac] == '#')
                .count();
            // println!("({}, {}) => {}", r, c, adj_occupied);
            next_grid[r][c] = match (cell, adj_occupied) {
                ('L', 0) => '#',
                ('#', n) if n > 3 => 'L',
                (&s, _) => s
            }
        }
    }
    next_grid
}

fn count_occupied(grid: &Grid) -> usize {
    grid.iter().map(|x| x.iter()).flatten().filter(|x| x == &&'#').count()
}

fn part1(grid: &Grid) {
    let mut grid: Grid = grid.clone();
    let mut next: Grid = generation(&grid);
    while next != grid {
        grid = next;
        next = generation(&grid);
    }
    println!("{}", count_occupied(&grid))
}


fn part2() {
}

pub fn print_grid(grid: &Grid) {
    let k = grid.iter().map(|x| x.iter().join("")).join("\n");
    println!("{}", k);
}

pub fn main() {
    let grid: Grid = io::stdin()
        .lock()
        .lines()
        .map(|l| l.unwrap().chars().collect_vec())
        .collect();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&grid),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
