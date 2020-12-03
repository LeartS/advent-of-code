use std::io::{self, BufRead};

fn flat_index(width: usize, row: usize, col: usize) -> usize {
    row * width + col
}

fn count_trees(flat_matrix: &Vec<bool>, width: usize, row_step: usize, col_step: usize) -> usize {
    let mut r = 0;
    let mut c = 0;
    let mut trees_count = 0;
    while flat_index(width, r, c) < flat_matrix.len() {
        if !flat_matrix[flat_index(width, r, c)] { trees_count = trees_count + 1; }
        r = r + row_step;
        c = (c + col_step) % width;
    }
    trees_count
}

fn read_treemap() -> ((usize, usize), Vec<bool>) {
    let stdin = io::stdin();
    let mut lines = stdin.lock().lines().peekable();
    let width = lines.peek()
        .unwrap()
        .as_ref()
        .unwrap()
        .len()
        .clone();
    let matrix: Vec<bool> = lines
        .map(|l| l.expect("Could not read line"))
        .flat_map(|l| l.chars().collect::<Vec<char>>())
        .map(|c| if c == '.' { true } else { false })
        .collect::<Vec<_>>();
    ((width, matrix.len() / width), matrix)
}

fn part1() {
    let ((width, _height), treemap) = read_treemap();
    let trees = count_trees(&treemap, width, 1, 3);
    println!("{} trees", trees);
}

fn part2() {
    let ((width, _height), treemap) = read_treemap();
    let slopes = vec![(1, 1), (1, 3), (1, 5), (1, 7), (2, 1)];
    let mut res = 1;
    for (row_step, col_step) in slopes {
        res = res * count_trees(&treemap, width, row_step, col_step)
    }
    // let valid_count = count_valid_passwords(check_valid_password_positions);
    println!("{} trees", res);
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
