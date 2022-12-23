use itertools::Itertools;

use aoc2022;

type Board = Vec<Vec<char>>;
type BoardBoundaries = (Vec<(usize, usize)>, Vec<(usize, usize)>);
type Pos = (usize, usize, Direction);

#[derive(Clone, Copy, Debug)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

#[derive(Debug)]
enum TurnDirection {
    Clockwise,
    CounterClockwise,
}

#[derive(Debug)]
enum Motion {
    Forward(usize),
    Turn(TurnDirection),
}

use Direction::*;
use Motion::*;
use TurnDirection::*;

fn read_input() -> (Board, Vec<Motion>) {
    let line_iterator = &mut aoc2022::io::iterate_lines();
    let rows = line_iterator
        .take_while(|line| line.trim().len() > 0)
        .map(|line| line.to_owned().chars().collect_vec())
        .collect_vec();
    let width = rows.iter().map(|row| row.len()).max().expect("No rows?");
    let board = rows
        .to_owned()
        .iter_mut()
        .map(|row| {
            row.resize(width, ' ');
            row.to_owned()
        })
        .collect_vec();
    let motion_plan_line = line_iterator.next().expect("Missing motion plan");
    let motion_plan = parse_motion_plan(&motion_plan_line);
    (board, motion_plan)
}

/// Advances by one step in the current facing direction,
/// handling walls and wraparounds
fn advance(board: &Board, board_boundaries: &BoardBoundaries, position: Pos) -> Pos {
    let new_position @ (x, y, _d) = match position {
        (x, y, Up) => {
            let (min_y, max_y) = board_boundaries.1[x];
            if y == 0 || y - 1 < min_y {
                (x, max_y, Up)
            } else {
                (x, y - 1, Up)
            }
        }
        (x, y, Down) => {
            let (min_y, max_y) = board_boundaries.1[x];
            if y + 1 > max_y {
                (x, min_y, Down)
            } else {
                (x, y + 1, Down)
            }
        }
        (x, y, Right) => {
            let (min_x, max_x) = board_boundaries.0[y];
            if x + 1 > max_x {
                (min_x, y, Right)
            } else {
                (x + 1, y, Right)
            }
        }
        (x, y, Left) => {
            let (min_x, max_x) = board_boundaries.0[y];
            if x == 0 || x - 1 < min_x {
                (max_x, y, Left)
            } else {
                (x - 1, y, Left)
            }
        }
    };
    match board[y][x] {
        '#' => position,
        '.' => new_position,
        _ => panic!("Unexpected move to invalid board cell {},{}", x, y),
    }
}

fn apply_motion(
    board: &Board,
    board_boundaries: &BoardBoundaries,
    position: Pos,
    motion: Motion,
) -> Pos {
    match (motion, position) {
        (Turn(Clockwise), (x, y, Up)) => (x, y, Right),
        (Turn(Clockwise), (x, y, Right)) => (x, y, Down),
        (Turn(Clockwise), (x, y, Down)) => (x, y, Left),
        (Turn(Clockwise), (x, y, Left)) => (x, y, Up),
        (Turn(CounterClockwise), (x, y, Up)) => (x, y, Left),
        (Turn(CounterClockwise), (x, y, Right)) => (x, y, Up),
        (Turn(CounterClockwise), (x, y, Down)) => (x, y, Right),
        (Turn(CounterClockwise), (x, y, Left)) => (x, y, Down),
        (Forward(steps), pos) => {
            (1..=steps).fold(pos, |pos, _| advance(board, board_boundaries, pos))
        }
    }
}

fn parse_motion_plan(motion_plan: &str) -> Vec<Motion> {
    motion_plan
        .chars()
        .group_by(|&c| c == 'R' || c == 'L')
        .into_iter()
        .map(|(a, b)| match (a, b.collect::<String>().as_str()) {
            (true, "R") => Motion::Turn(TurnDirection::Clockwise),
            (true, "L") => Motion::Turn(TurnDirection::CounterClockwise),
            (false, steps_str) => Motion::Forward(steps_str.parse().expect("Invalid")),
            _ => panic!("Invalid"),
        })
        .collect_vec()
}

fn precompute_board_boundaries(board: &Board) -> BoardBoundaries {
    let row_boundaries = board
        .iter()
        .map(|row| {
            let first = row
                .iter()
                .find_position(|&&cell| cell != ' ')
                .expect("no valid cells in row")
                .0;
            let last = row
                .iter()
                .enumerate()
                .rev()
                .find(|&(_col, &cell)| cell != ' ')
                .expect("No valid cells in row")
                .0;
            (first, last)
        })
        .collect_vec();
    let col_boundaries = (0..board[0].len())
        .map(|col_index| {
            let col = board.iter().map(|row| row[col_index].clone()).collect_vec();
            let first = col
                .iter()
                .find_position(|&&cell| cell != ' ')
                .expect("no valid cells in col")
                .0;
            let last = col
                .iter()
                .enumerate()
                .rev()
                .find(|&(_col, &cell)| cell != ' ')
                .expect("no valid cells in col")
                .0;
            (first, last)
        })
        .collect_vec();
    (row_boundaries, col_boundaries)
}

fn password((x, y, direction): Pos) -> usize {
    let direction_number = match direction {
        Right => 0,
        Down => 1,
        Left => 2,
        Up => 3,
    };
    1000 * (y + 1) + 4 * (x + 1) + direction_number
}

fn part1() {
    let (board, motion_plan) = read_input();
    let boundaries = precompute_board_boundaries(&board);
    let mut pos: Pos = (boundaries.0[0].0, 0, Right);
    // println!("Starting position: {:?}", pos);
    for motion in motion_plan {
        // println!("{:?}", motion);
        pos = apply_motion(&board, &boundaries, pos, motion);
        // println!("New position: {:?}", pos);
    }
    println!(
        "The final password is {} (final pos: row {}, col {}, facing {:?})",
        password(pos),
        pos.1 + 1,
        pos.0 + 1,
        pos.2
    );
}

fn part2() {
    todo!()
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
