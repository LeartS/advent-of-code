use itertools::Itertools;
use std::collections::HashSet;

use aoc2022;

type Pos = (isize, isize);

fn adj((row, col): Pos, round: usize) -> impl Iterator<Item = Pos> {
    vec![
        (-1, 0),  // N
        (-1, 1),  // NE
        (-1, -1), // NW
        (1, 0),   // S
        (1, 1),   // SE
        (1, -1),  // SW
        (0, -1),  // W
        (-1, -1), // NW
        (1, -1),  // SW
        (0, 1),   // E
        (-1, 1),  // NE
        (1, 1),   // SE
    ]
    .into_iter()
    .map(move |(row_offset, col_offset)| (row + row_offset, col + col_offset))
    .cycle()
    .skip(3 * (round % 4))
    .take(12)
}

fn proposed_position(elfs: &HashSet<Pos>, round: usize, elf: Pos) -> Pos {
    let candidates = adj(elf, round).collect_vec();
    match candidates.iter().find(|x| elfs.contains(x)) {
        None => elf,
        Some(_) => {
            let free_direction = candidates
                .as_slice()
                .chunks(3)
                .find(|chunk| chunk.iter().all(|pos| !elfs.contains(pos)));
            match free_direction {
                None => elf,
                Some(direction_cells) => direction_cells[0],
            }
        }
    }
}

// Returns the number of elfs that moved
fn simulate_round(elfs: &mut HashSet<Pos>, round: usize) -> usize {
    let elf_with_proposals = elfs
        .iter()
        .map(|elf| (*elf, proposed_position(&*elfs, round, *elf)))
        .collect_vec();
    let contested_proposals: HashSet<Pos> = elf_with_proposals
        .iter()
        .map(|&(_elf, proposal)| proposal)
        .duplicates()
        .collect();
    let mut moved = 0;
    for (elf, proposed_position) in elf_with_proposals {
        if !contested_proposals.contains(&proposed_position) && elf != proposed_position {
            moved += 1;
            elfs.remove(&elf);
            elfs.insert(proposed_position);
        }
    }
    moved
}

fn bounding_box(elfs: &HashSet<Pos>) -> (Pos, Pos) {
    let mut top_left = (isize::MAX, isize::MAX);
    let mut bottom_right = (isize::MIN, isize::MIN);
    for &(row, col) in elfs {
        if row < top_left.0 {
            top_left.0 = row;
        }
        if col < top_left.1 {
            top_left.1 = col;
        }
        if row > bottom_right.0 {
            bottom_right.0 = row;
        }
        if col > bottom_right.1 {
            bottom_right.1 = col;
        }
    }
    (top_left, bottom_right)
}

fn empty_tiles_in_area(elfs: &HashSet<Pos>, boundary: (Pos, Pos)) -> usize {
    let ((min_row, min_col), (max_row, max_col)) = boundary;
    (min_row..=max_row)
        .cartesian_product(min_col..=max_col)
        .filter(|pos| !elfs.contains(pos))
        .count()
}

fn print(elfs: &HashSet<Pos>) {
    let ((min_row, min_col), (max_row, max_col)) = bounding_box(elfs);
    for row in min_row..=max_row {
        for col in min_col..=max_col {
            if elfs.contains(&(row, col)) {
                print!("#")
            } else {
                print! {"."}
            }
        }
        println!();
    }
    println!("\n");
}

fn read_elfs() -> HashSet<Pos> {
    aoc2022::io::iterate_lines()
        .enumerate()
        .flat_map(|(row, line)| {
            line.chars()
                .enumerate()
                .filter(|(_, cell)| *cell == '#')
                .map(|(col, _)| (row as isize, col as isize))
                .collect_vec()
        })
        .collect()
}

fn part1() {
    let mut elfs = read_elfs();
    for round in 0..10 {
        // print(&elfs);
        simulate_round(&mut elfs, round);
    }
    println!(
        "Empty tiles in min containing area: {}",
        empty_tiles_in_area(&elfs, bounding_box(&elfs))
    )
}

fn part2() {
    let mut elfs = read_elfs();
    let mut round = 0;
    let mut moved = 1;
    while moved > 0 {
        moved = simulate_round(&mut elfs, round);
        round += 1
    }
    println!("First round with no movement: {}", round);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
