use std::collections::{HashSet, VecDeque};

use aoc2022;

type Pos = (usize, usize);

#[derive(Debug)]
enum Forecast {
    Clear,
    Blizzard,
    Wall,
}

struct Map<'a> {
    pub data: &'a Vec<Vec<char>>,
    pub width: usize,
    pub height: usize,
}

fn wrapping_sub(n: usize, sub: usize, max: usize) -> usize {
    (n as isize - sub as isize).rem_euclid(max as isize) as usize
}

impl<'a> Map<'a> {
    fn new(raw_map: &'a Vec<Vec<char>>) -> Map<'a> {
        Self {
            data: raw_map,
            width: raw_map[0].len(),
            height: raw_map.len(),
        }
    }

    fn forecast(self: &Self, (row, col): Pos, minute: usize) -> Forecast {
        match (row, col) {
            (0, 1) => Forecast::Clear,
            (0, _) => Forecast::Wall,
            (_, 0) => Forecast::Wall,
            (_, c) if c == self.width - 1 => Forecast::Wall,
            (r, c) if r == self.height - 1 && c == self.width - 2 => Forecast::Clear,
            (r, _) if r == self.height - 1 => Forecast::Wall,
            (r, c) => {
                let blizzard = self.data[r][wrapping_sub(c - 1, minute, self.width - 2) + 1] == '>'
                    || self.data[r][(c - 1 + minute) % (self.width - 2) + 1] == '<'
                    || self.data[(r - 1 + minute) % (self.height - 2) + 1][c] == '^'
                    || self.data[wrapping_sub(r - 1, minute, self.height - 2) + 1][c] == 'v';
                match blizzard {
                    true => Forecast::Blizzard,
                    false => Forecast::Clear,
                }
            }
        }
    }
}

fn print_forecast(map: &Map, minute: usize) {
    for r in 0..map.height {
        for c in 0..map.width {
            match map.forecast((r, c), minute) {
                Forecast::Blizzard => print!("x"),
                Forecast::Clear => print!("."),
                Forecast::Wall => print!("#"),
            }
        }
        println!();
    }
    println!();
    println!();
}

fn shortest_path(map: &Map, from: Pos, to: Pos, start_time: usize) -> Vec<Pos> {
    let mut queue = VecDeque::from([vec![from]]);
    let mut visited: HashSet<(Pos, usize)> = HashSet::new();
    loop {
        let path = queue.pop_front().expect("No path found!");
        let (&pos, m) = (path.last().expect("Empty path??"), path.len());
        if pos == to {
            return path;
        }
        for next_pos in
            aoc2022::grid::taxicab_neighbours(map.width, map.height, pos).chain(vec![pos])
        {
            if visited.contains(&(next_pos, m + 1)) {
                continue;
            }
            match map.forecast(next_pos, start_time + m + 1) {
                Forecast::Clear => {
                    visited.insert((next_pos, m + 1));
                    let mut newpath = path.clone();
                    newpath.push(next_pos);
                    queue.push_back(newpath);
                }
                _ => continue,
            }
        }
    }
}

fn part1() {
    let raw_map = aoc2022::io::read_matrix(|c| c);
    let map = Map::new(&raw_map);
    let shortest_path = shortest_path(&map, (0, 1), (map.height - 1, map.width - 2), 0);
    println!("Can reach the exit in {} minutes", shortest_path.len());
}

fn part2() {
    let raw_map = aoc2022::io::read_matrix(|c| c);
    let map = Map::new(&raw_map);
    let path_to_goal = shortest_path(&map, (0, 1), (map.height - 1, map.width - 2), 0);
    let path_back = shortest_path(
        &map,
        (map.height - 1, map.width - 2),
        (0, 1),
        path_to_goal.len(),
    );
    let path_to_goal_again = shortest_path(&map, (0, 1), (map.height - 1, map.width - 2), path_to_goal.len() + path_back.len());
    println!(
        "Can go to goal, back, and to goal again in {} minutes ({} + {} + {})",
        path_to_goal.len() + path_back.len() + path_to_goal_again.len(),
        path_to_goal.len(),
        path_back.len(),
        path_to_goal_again.len(),
    );
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
