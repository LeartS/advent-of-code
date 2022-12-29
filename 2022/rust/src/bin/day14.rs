use itertools::{self, Either, Itertools, MinMaxResult};
use std::fmt;

use aoc2022;

#[derive(Clone, Copy, PartialEq)]
enum Tile {
    Air,
    Rock,
    Sand,
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let a = match *self {
            Tile::Air => '.',
            Tile::Rock => '#',
            Tile::Sand => 'O',
        };
        write!(f, "{}", a)
    }
}

type Coord = (usize, usize);
type Line = (Coord, Coord);

fn parse_coord(coord_str: &str) -> Coord {
    coord_str
        .split(',')
        .map(|n| n.parse::<usize>().expect("invalid coordinate"))
        .collect_tuple()
        .expect("invalid coordinates")
}

fn parse_path(line: &str) -> Vec<Line> {
    line.split(" -> ")
        .map(parse_coord)
        .tuple_windows()
        .collect_vec()
}

fn bounds(paths: &Vec<Vec<Line>>) -> ((usize, usize), (usize, usize)) {
    let (xs, ys): (Vec<usize>, Vec<usize>) = paths
        .iter()
        .flat_map(|path| path.iter())
        .flat_map(|&(from, to)| vec![from.0, from.1, to.0, to.1])
        .enumerate()
        .partition_map(|(i, n)| {
            if i % 2 == 0 {
                Either::Left(n)
            } else {
                Either::Right(n)
            }
        });
    let x_bounds = match xs.iter().minmax() {
        MinMaxResult::MinMax(x, y) => (*x, *y),
        _ => panic!("Less than 2 xs"),
    };
    let y_bounds = match ys.iter().minmax() {
        MinMaxResult::MinMax(min, max) => (*min, *max),
        _ => panic!("Less than 2 ys"),
    };
    (x_bounds, y_bounds)
}

struct Map {
    grid: Vec<Vec<Tile>>,
    sand_source: Coord,
    pub left: usize,
    pub right: usize,
    pub width: usize,
    pub height: usize,
}

impl Map {
    fn from_rock_paths(rock_paths: &Vec<Vec<Line>>, add_floor: bool) -> Self {
        let ((min_x, max_x), (_, max_y)) = bounds(rock_paths);
        let min_y = 0;
        let width = (max_x - min_x + 1) as usize;
        let height = (max_y - min_y + 1) as usize;
        let mut map = vec![vec![Tile::Air; 1001]; 1001];
        for path in rock_paths {
            for (from, to) in path {
                for x in std::cmp::min(from.0, to.0)..=std::cmp::max(from.0, to.0) {
                    for y in std::cmp::min(from.1, to.1)..=std::cmp::max(from.1, to.1) {
                        map[y][x] = Tile::Rock;
                    }
                }
            }
        }
        if add_floor {
            for x in 0..1001 {
                map[height + 1][x] = Tile::Rock;
            }
        }
        Self {
            grid: map,
            sand_source: (500, 0),
            left: if add_floor { 0 } else { min_x },
            right: if add_floor { 1000 } else { max_x },
            width: if add_floor { 1000 } else { width },
            height: if add_floor { height + 2 } else { height },
        }
    }

    fn in_bounds(&self, (x, y): Coord) -> bool {
        x >= self.left && x < self.right && y < self.height
    }

    fn drop_sand(&mut self) -> Option<Coord> {
        let mut sand_pos = self.sand_source;
        loop {
            let (sand_x, sand_y) = sand_pos;
            let new_sand_pos = vec![
                (sand_x, sand_y + 1),
                (sand_x - 1, sand_y + 1),
                (sand_x + 1, sand_y + 1),
            ]
            .into_iter()
            .find(|&(x, y)| !self.in_bounds((x, y)) || self.grid[y][x] == Tile::Air);
            match new_sand_pos {
                None => {
                    self.grid[sand_y][sand_x] = Tile::Sand;
                    return Some((sand_x, sand_y));
                }
                Some((x, y)) => {
                    if !self.in_bounds((x, y)) {
                        return None;
                    }
                    sand_pos = (x, y);
                }
            }
        }
    }
}

impl fmt::Display for Map {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for y in 0..self.height {
            for x in self.left..self.left + self.width {
                write!(f, "{}", self.grid[y][x]).expect("Eh");
            }
            write!(f, "\n");
        }
        write!(f, "\n")
    }
}

fn part1() {
    let paths = aoc2022::io::iterate_lines()
        .map(|line| parse_path(&line))
        .collect_vec();
    let mut map = Map::from_rock_paths(&paths, false);
    println!("{}", map);
    println!();
    let mut n = 0;
    loop {
        match map.drop_sand() {
            Some((x, y)) => {
                println!("Sand dropped to {:?}", (x, y));
                println!("{}", map);
                println!();
                n += 1;
            }
            None => {
                println!("Sand before abyss {}", n);
                return;
            }
        }
    }
}

fn part2() {
    let paths = aoc2022::io::iterate_lines()
        .map(|line| parse_path(&line))
        .collect_vec();
    let mut map = Map::from_rock_paths(&paths, true);
    let mut n = 0;
    loop {
        match map.drop_sand() {
            Some((500, 0)) => {
                println!("Sand dropped until stuck {}", n + 1);
                return;
            }
            Some((x, y)) => {
                println!("Sand dropped to {:?}", (x, y));
                n += 1;
            }
            _ => panic!("Unexpected"),
        }
    }
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
